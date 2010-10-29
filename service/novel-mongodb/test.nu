(load "NuJSON")
(load "NuHTTPHelpers")

(set ROOT "http://localhost:5000")

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

;(curl POST "/signup" (dict user:"test" password:"test"))
;(curl POST "/reset" (dict x:1))

(set result (curl GET "/count" nil))
(set count ((result JSONValue) count:))

(if (eq count 0)
    (10 times:
        (do (i)
            (set latitude i)
            (10 times:
                (do (j)
                    (set longitude j)
                    (curl POST "/stickup" (dict user:"test"
                                                password:"test"
                                                latitude:(* 11.1 latitude)
                                                longitude:(* 11.1 longitude)
                                                message:"Hi there #{i}_#{j}")))))))

;; gets the nearest posts
(curl GET "/stickups" (dict latitude:50.0 longitude:50.0 count:5))
