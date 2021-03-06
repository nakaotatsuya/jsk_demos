(load "package://pr2eus/pr2-interface.l")

(defvar *points* nil)
(defvar *pcloudflag* nil)
(defvar *time-count* nil)

(defun is-old-msg (msg)
  (let ((htime (send msg :header :stamp)))
    (cond ((> 0 (send (ros::time- htime *time-count*) :to-sec))
           (ros::ros-debug "message is old, return with no action")
	   t))))

(defun pcloud-cb (msg)
  (if (is-old-msg msg) (return-from pcloud-cb nil))
  (unless *pcloudflag*
    (setq *points* msg)
    (setq *pcloudflag* t)))

(defun rotational-divide-filter (pos)
  (let ((zydeg (atan2 (elt pos 1) (elt pos 2))))
    (if (< zydeg 0) (setq zydeg (+ zydeg 2pi)))
    (if (= 0 filternum)
	(if (or (>= zydeg (/ (* 2pi (1- (* 2 divnum))) (* 2 divnum)))
		(< zydeg (/ 2pi (* 2 divnum))))
	    t
	  nil)
      (if (and (>= zydeg (/ (* 2pi (1- (* 2 filternum))) (* 2 divnum)))
	       (< zydeg (/ (* 2pi (1+ (* 2 filternum))) (* 2 divnum))))
	  t
	nil))
    ))

(defun get-bin (d &key (step 3) (max-num 1.0) (min-num 0.0))
 (if (= d max-num) (- step 1)
   (floor (/ d (/ (- max-num min-num) step)))))

(defmethod pointcloud
  (:hs-hist (&key (h-step 3) (s-step 3))
    (let ((col (send self :carray))
	  (hist (make-array
		 (list h-step s-step)
		 :element-type float-vector)))
      (dotimes (i (send self :size))
	(let* ((his (rgb2his (scale 255 (matrix-row col i))))
	       (h-bin (get-bin (elt his 0) :step h-step :max-num 360.0))
	       (s-bin (get-bin (elt his 2) :step s-step)))
	  (incf (aref hist h-bin s-bin))))
      (scale-matrix (/ 1.0 (send self :size)) hist))))

(defun rotational-divide-hist (msg divnum filternum h-step s-step)
  (let ((3dp (make-eus-pointcloud-from-msg msg)) kinect-cds rgripper-cds)
    (ros::spin-once)
    (send *pr2* :angle-vector (send *ri* :state :potentio-vector))
    (setq rgripper-cds (send *pr2* :r_gripper_tool_frame_lk :copy-worldcoords))
    (setq kinect-cds (send (send *pr2* :head_mount_kinect_rgb_optical_frame_lk) :copy-worldcoords))
    (send 3dp :transform-points (send rgripper-cds :transformation kinect-cds))
    (send 3dp :nfilter :key #'rotational-divide-filter)
    (push 3dp *lst*)
    (send 3dp :hs-hist :h-step h-step :s-step s-step)))

(defun divided-pcl-vis (pcs)
  (when (not (boundp '*irtviewer*)) (make-irtviewer))
  (send *irtviewer* :objects pcs)
  (let ((num (length pcs)) bb r angle cubes)
    (setq bb (make-bounding-box (flatten (send-all pcs :points))))
    (setq r (/ (elt (v- (send bb :maxpoint) (send bb :minpoint)) 1) 2));;radius
    (dotimes (i num)
      (setq angle (* (+ i 1) (/ -2pi num)))
      (send (elt pcs i) :transform-points
	    (make-coords :rpy (float-vector 0 0 angle)))
      (send (elt pcs i) :transform-points
	    (make-coords :pos (float-vector 0 (* angle r) 0)))
      )
    ;;(setq bb (make-bounding-box (flatten (send-all pcs :points))))
    ;;(setq r (/ (elt (v- (send bb :maxpoint) (send bb :minpoint)) 1) 2pi))
    ;; add feature color cubes
    (dotimes (i num)
      (let* ((hstep 10) (sstep 3)
	     (hist (send (elt pcs i) :hs-hist :h-step hstep :s-step sstep))
	     vmax idx size cu (cnt 0))
	(setq hist (coerce (array-entity hist) cons))
	(while t
	  (setq vmax (apply #'max hist))
	  (when (< vmax 0.05) (return))
	  (setq idx (position vmax hist))
	  (setf (elt hist idx) 0.0)
	  (setq h (* 360 (/ 1.0 hstep) (+ (/ idx sstep) 0.5))
		s (* (/ 1.0 sstep) (+ (mod idx sstep) 0.5)))
	  (setq span (* r (/ 2pi num)) size (* 0.8 span))
	  (setq cu (make-cube size size size))
	  (send cu :translate (float-vector (- (+ size (* span cnt))) (* (+ i 1) (/ -2pi num) r) 0))
	  (send cu :set-color (scale (/ 1.0 256) (coerce (hvs2rgb h 0.8 s) float-vector)))
	  (push cu cubes)
	  (incf cnt))
	))
    (send *irtviewer* :objects (append pcs cubes))
    ))

(defun create-hist (divnum h-step s-step)
  "create histogram model from surroundings
divnum division number of around model
h-step bin size of hue
s-step bin size of saturation"
  (let (hist-lst init-wrist-r)
    (setq *lst* nil) ;; each parts will be stored
    (send *ri* :stop-grasp :rarm)
    (send *pr2* :rarm :inverse-kinematics (make-coords :pos #f(700 0 1200) :rot #2f((0 0 -1)(0 1 0)(1 0 0))) :rotation-axis t)
    (setq init-wrist-r (send *pr2* :rarm :wrist-r :joint-angle))
    (send *pr2* :look-at-hand :rarm)
    (send *ri* :angle-vector (send *pr2* :angle-vector))
    (send *ri* :wait-interpolation)
    (unix::sleep 3)
    (send *ri* :start-grasp :rarm)
    (dotimes (i divnum)
      (send *pr2* :rarm :wrist-r :joint-angle (+ init-wrist-r (* i (/ 360.0 divnum))))
      (send *ri* :angle-vector (send *pr2* :angle-vector) 1000)
      (send *ri* :wait-interpolation)
      (setq *pcloudflag* nil)
      (setq *time-count* (ros::time-now))
      (while (not *pcloudflag*)
	(ros::spin-once)
	(ros::sleep))
      (ros::ros-info "get points, create histgram(~A)" i)
      (when (= 0 (* (send *points* :height) (send *points* :width)))
	(ros::ros-error "no data in msg")
	(return-from create-hist))
      (push (rotational-divide-hist *points* divnum i h-step s-step) hist-lst))
    hist-lst))

(defun init-setting()
  ";; Initialization setting for create color histogram
(init-setting) ;; initialization
(setq hist (create-hist 8 10 10)) ;; crate histogram list, you should put a object on PR2's hand.
(divided-pcl-vis *lst*) ;; view results
"
  (unless (not (boundp '*pr2*)) (return-from init-setting nil))
  (ros::roseus "create_hist")
  (setq *time-count* (ros::time-now))
  (ros::subscribe "/grasp_object_points_filtered" sensor_msgs::PointCloud2 #'pcloud-cb)
  (pr2)
  (setq *ri* (instance pr2-interface :init))
  (ros::spin-once)
  (send *pr2* :angle-vector (send *ri* :state :potentio-vector)))

(warn "~A~%" (documentation 'init-setting))
;;(init-setting)
;;(setq hist (create-hist 8 10 10))
;;(divided-pcl-vis *lst)

(defun test (filename)
  (create-hist 16 1 1)
  (divided-pcl-vis *lst*)
  (dump-loadable-structure filename *lst*)
  )
