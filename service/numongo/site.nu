(load "NuMarkup:xhtml")
(load "NuJSON")
(load "NuMongoDB")

;; connect to database
(set mongo (NuMongoDB new))
(set connected (mongo connectWithOptions:nil))

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
                                    (&td (stickup latitude:))
                                    (&td (stickup longitude:))
                                    (&td (stickup message:)))))))))

(post "/stickup"
      (set stickup (REQUEST post))
      (puts (stickup description))
      (set query (dict name:(stickup user:) password:(stickup password:)))
      (if (mongo findOne:query inCollection:"stickup.users")
          (then
               (stickup removeObjectForKey:"password")
               (stickup time:((NSDate date) description))
               (mongo insert:stickup intoCollection:"stickup.stickups")
               ((dict status:200 message:"Thank you.")
                JSONRepresentation))
          (else
               ((dict status:403 message:"Unable to post stickup.")
                JSONRepresentation))))

(get "/stickups"
     (puts ((REQUEST query) description))
     ((dict status:200 stickups:(mongo findArray:nil inCollection:"stickup.stickups"))
      JSONRepresentation))

(post "/stickups"
      (puts ((REQUEST query) description))
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
                  (mongo insert:(dict name:user password:password) intoCollection:"stickup.users")
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
