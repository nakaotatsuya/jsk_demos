(defclass hammer-hand
  :super cascaded-link
  :slots (hammer hand j0))

(defmethod hammer-hand
  (:init
   (&rest args)
   (send-super* :init args)
   (let (hammer-stick hammer-body hammer-stick2 hand-co)
     ;; bodyset-link をつくる
     (setq hammer-stick (make-cylinder 10 100))
     (send hammer-stick :set-color :red)
     (setq hammer-body (make-cube 50 100 50))
     (send hammer-body :translate (float-vector 0 0 100))
     (send hammer-body :set-color :yellow)
     (send hammer-stick :assoc hammer-body)
     (setq hammer
           (instance bodyset-link :init (make-cascoords)
                     :bodies (list hammer-stick hammer-body)))

     (setq hammer-stick2 (make-cylinder 20 20))
     (send hammer-stick2 :set-color :green)
     (send hammer-stick2 :rotate (deg2rad 90) :y)
     (send hammer-stick2 :translate (float-vector 0 0 -10))
     (setq hand
           (instance bodyset-link :init (make-cascoords)
                     :bodies (list hammer-stick2)))

     ;; joint をつくる
     (setq j0
           (instance rotational-joint :init
                     :parent-link hand
                     :child-link hammer
                     :axis :x))

     ;; ルートから順番に assoc
     (send self :assoc hand)
     (send hand :assoc hammer)

     ;; links, joint-list は cascaded-link で宣言されている
     (setq links (list hand hammer))
     (setq joint-list (list j0))

     ;; 忘れずに
     (send self :init-ending)
     )
   self)

  (:hand (&rest args) (forward-message-to j0 args))
  )

(setq *hammer-hand* (instance hammer-hand :init))
(objects (list *hammer-hand*))
  
