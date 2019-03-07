#!/usr/bin/env roseus

(ros::load-ros-manifest "geometry_msgs")
(ros::roseus "knock")

(setq *topic* "/arm_controller/cartesian_wrench/command")

(ros::advertise *topic* geometry_msgs::Wrench 1)

(defun knock()
  (send *ri* :start-grasp :wait t :effort 60)
  (let ((msg (instance geometry_msgs::Wrench :init))
	(angle-vector (send *fetch* :angle-vector)))
    (dotimes (i 3)
      (ros::rate 10)
      (send (send msg :force) :x 50)
      (send (send msg :force) :z 25)
      (dotimes (i 10)
	(ros::publish *topic* msg)
	(ros::sleep))
      
      (send (send msg :force) :x -50)
      (send (send msg :force) :z -25)
      (dotimes (i 10)
	(ros::publish *topic* msg)
	(ros::sleep))
      (send *ri* :angle-vector (send *fetch* :angle-vector angle-vector) 1000)
      (send *ri* :wait-interpolation)
     )))

