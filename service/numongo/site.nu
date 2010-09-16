(load "NuMarkup:xhtml")
(load "NuJSON")
(load "NuMongoDB")
(load "NuHTTPHelpers")

;; connect to database
(set mongo (NuMongoDB new))
(set connected (mongo connectWithOptions:nil))
(mongo authenticateUser:"stickup" withPassword:"stickup" forDatabase:"stickup")

(mongo ensureCollection:"stickup.stickups" hasIndex:(dict location:"2d") withOptions:0)

(post "/reset"
      (mongo dropCollection:"users" inDatabase:"stickup")
      (mongo dropCollection:"stickups" inDatabase:"stickup")
      ((dict status:200 message:"Reset database.") JSONRepresentation))

(get "/"
     (&html (&head)
            (&body (&h1 "Hello")
                   (&p "This is stickup.")
                   (&table
                          (&tr (&th "user")
                               (&th "time")
                               (&th "latitude")
                               (&th "longitude")
                               (&th "message"))
                          ((mongo findArray:nil inCollection:"stickup.stickups") map:
                           (do (stickup)
                               (&tr (&td (stickup user:))
                                    (&td (stickup time:))
                                    (&td ((stickup location:) latitude:))
                                    (&td ((stickup location:) longitude:))
                                    (&td (stickup message:)))))))))

(post "/stickup"
      (set stickup (REQUEST post))
      (set user (mongo findOne:(dict name:(stickup user:)) inCollection:"stickup.users"))
      (unless user
              (set user (dict name:(stickup user:) password:(stickup password:)))
              (mongo insertObject:user intoCollection:"stickup.users"))
      (if (eq (user password:) (stickup password:))
          (then
               (stickup removeObjectForKey:"password")
               (stickup time:((NSDate date) description))
               (stickup location:(dict latitude:((stickup latitude:) floatValue)
                                       longitude:((stickup longitude:) floatValue)))
               (stickup removeObjectForKey:"latitude")
               (stickup removeObjectForKey:"longitude")
               (mongo insertObject:stickup intoCollection:"stickup.stickups")
               ((dict status:200 message:"Thank you." saved:stickup)
                JSONRepresentation))
          (else
               ((dict status:403 message:"Unable to post stickup.")
                JSONRepresentation))))

(get "/stickups"
     (mongo ensureCollection:"stickup.stickups" hasIndex:(dict location:"2d") withOptions:0)
     (set query (dict))
     (if (and (set latitude (((REQUEST query) latitude:) floatValue))
              (set longitude (((REQUEST query) longitude:) floatValue)))
         (query location:(dict $near:(dict latitude:latitude longitude:longitude))))
     (unless (set count (((REQUEST query) count:) intValue))
             (set count 10))
     ((dict status:200 stickups:(mongo findArray:query
                                       inCollection:"stickup.stickups"
                                       returningFields:nil
                                       numberToReturn:count
                                       numberToSkip:0))
      JSONRepresentation))

(get "/count"
     (set count (mongo countWithCondition:nil inCollection:"stickups" inDatabase:"stickup"))
     ((dict status:200 count:count) JSONRepresentation))

(post "/stickups"
      ((dict status:200 stickups:(mongo findArray:nil inCollection:"stickup.stickups"))
       JSONRepresentation))

(post "/signup"
      (set info (REQUEST post))
      (set user (info user:))
      (set password (info password:))
      ((cond ((eq user nil)
              (dict status:403 message:"Please specify a user"))
             ((eq password nil)
              (dict status:403 message:"Please specify a password"))
             ((mongo findOne:(dict name:user) inCollection:"stickup.users")
              (dict status:403 message:"This user already exists."))
             (else
                  (mongo insertObject:(dict name:user password:password) intoCollection:"stickup.users")
                  (dict status:200 message:(+ "Successfully registered " user "."))))
       JSONRepresentation))

(get "/users"
     (set users (mongo findArray:nil
                       inCollection:"stickup.users"
                       returningFields:(dict password:0)
                       numberToReturn:1000
                       numberToSkip:0))
     ((dict status:200 users:users)
      JSONRepresentation))
