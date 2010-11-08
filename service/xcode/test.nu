(load "NuJSON")
(set SERVER "http://localhost:3000")

;; reset database
(set command (+ "curl -s " SERVER "/reset -d a=b"))
(puts command)
(set result (NSString stringWithShellCommand:command))
(puts result)

(set N 5)

;; post some stickups
(N times:
   (do (i)
       (N times:
          (do (j)
              (set latitude (+ 30 (* i 0.1)))
              (set longitude (+ -122 (* j 0.1)))
              (set command (+ "curl -s " SERVER "/stickup -d user=tim -d password=tim -d latitude="
                              latitude " -d longitude=" longitude " -d message='hello " i "," j "'"))
              (puts command)
              (set result (NSString stringWithShellCommand:command))
              (puts (result description))
              ))))

(set command (+ "curl -s " SERVER "/count"))
(puts command)
(set result (NSString stringWithShellCommand:command))
(puts ((result JSONValue) description))

(10 times:
    (do (i)
        (set command (+ "curl -s '" SERVER "/stickups?latitude=30.2&longitude=-121.9&count=4'"))
        (puts command)
        (set result (NSString stringWithShellCommand:command))))

(puts ((result JSONValue) description))

