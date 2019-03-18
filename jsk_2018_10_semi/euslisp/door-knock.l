#!/usr/bin/env roseus

(load "package://fetcheus/fetch-interface.l")
(load "knock.l")

(fetch-init)
(defun door-knock nil
  (send *fetch* :torso :waist-z :joint-angle 220)
  (send *ri* :angle-vector (send *fetch* :angle-vector) 7000)
  (send *ri* :wait-interpolation)
	
  (send *fetch* :rarm :inverse-kinematics (make-coords :pos #f(450 200 1200) :rpy (float-vector 0 -pi/2 pi/2)) :debug-view t)
  (send *ri* :angle-vector (send *fetch* :angle-vector) 5000)
  (send *ri* :wait-interpolation)

  (knock)

  (send *ri* :angle-vector (send *fetch* :reset-pose) 5000)
  (objects (list *fetch*))
  (send *irtviewer* :look-all *fetch*)
)
