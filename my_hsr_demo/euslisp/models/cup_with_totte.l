(defclass cup-object
  :super cascaded-link)

(defmethod cup-object
  (:init
   (&rest args &key (name "cup") (pos (float-vector 0 0 0)) (rot (unit-matrix 3)) &allow-other-keys)
   (let (link1 b1 b2 b3 b4 b5)
     (send-super* :init :name name args)

     (setq b1 (make-cylinder 50 100))
     (setq b2 (make-cylinder 45 95))
     (send b2 :locate #f(0 0 5))
     (setq b1 (body- b1 b2))
     (send b1 :set-color :red)

     (setq b3 (make-cylinder 30 10))
     (setq b4 (make-cylinder 25 10))
     (setq b3 (body- b3 b4))
     (setq b5 (make-cube 100 100 24))
     ;;(send b5 :set-color :white)
     (send b5 :locate #f(51 0 0))
     (setq b3 (body- b3 b5))
     (send b3 :locate #f(-50 0 50))
     (send b3 :rotate (deg2rad 90) :x)
     
     (send b3 :set-color :green)
     (send b1 :assoc b3)
     
     (setq link1 (instance bodyset-link :init (make-cascoords) :bodies (list b1 b3) :weight 1))

     (send self :assoc link1)

     ;; init-ending 
     (setq links (list link1))
     (send self :init-ending)
     (send self :move-to (make-coords :pos pos :rot rot))
     (send-all links :worldcoords)

     self))
  )

(defun cup (&rest args) (instance* cup-object :init args))
