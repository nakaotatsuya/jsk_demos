(defclass mizukiri
  :super cascaded-link)

(defmethod mizukiri
  (:init
   (&rest args &key (name "mizukiri") (pos (float-vector 0 0 0)) (rot (unit-matrix 3)) &allow-other-keys)
   (let (link1 b1 b2 b3 b4)
     (send-super* :init :name name args)

     (setq b1 (make-cube 100 130 40))
     (setq b2 (make-cube 95 125 35))
     (send b2 :locate #f(0 0 5))
     (setq b1 (body- b1 b2))
     (send b1 :set-color :white)

     (setq link1 (instance bodyset-link :init (make-cascoords) :bodies (list b1) :weight 10))

     (send self :assoc link1)

     ;; init-ending 
     (setq links (list link1))
     (send self :init-ending)
     (send self :move-to (make-coords :pos pos :rot rot))
     (send-all links :worldcoords)

     self))
  )

(defun mizukiri (&rest args) (instance* mizukiri :init args))

