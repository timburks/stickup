(load "NuJSON")
(load "NuHTTPHelpers")

(set ROOT "http://localhost:3000")

(set POST "POST")
(set GET "GET")

(function curl-command (method path options)
     (set command (+ "curl -s '" ROOT path))
     (if options
         (then
              (if (eq method "GET")
                  (then
                       (command appendString:"?")
                       (command appendString:
                                (((options allKeys) map:
                                  (do (key)
                                      (+ key "=" (((options key) stringValue) urlEncode))))
                                 componentsJoinedByString:"&"))
                       (command appendString:"'"))
                  (else
                       (command appendString:"'")
                       (options each:
                                (do (key value)
                                    (command appendString:(+ " -d " key "=" ((value stringValue) urlEncode))))))))
         (else
              (command appendString:"'")))
     command)

(function curl (method path options)
     (set command (curl-command method path options))
     (puts command)
     (set result (NSString stringWithShellCommand:command))
     (puts result)
     result)

(curl POST "/signup" (dict user:"test" password:"test"))
(curl POST "/reset" (dict x:1))

(set result (curl GET "/count" nil))
(set count ((result JSONValue) count:))

(set N 10)

(if (eq count 0)
    (N times:
       (do (i)
           (set latitude (+ 37 (* 1.0 (/ i N))))
           (N times:
              (do (j)
                  (set longitude (+ -122.5 (* 1.0 (/ j N))))
                  (curl POST "/stickup" (dict user:"test"
                                              password:"test"
                                              latitude:latitude
                                              longitude:longitude
                                              message:"Hi there #{i}_#{j}")))))))

;; gets the nearest posts
(curl POST "/stickups" (dict latitude:37.5 longitude:-122 count:5))