(define-module (signalo)
  #:use-module (gcrypt base64)
  #:use-module (ice-9 binary-ports)
  #:use-module (ice-9 pretty-print)
  #:use-module (ice-9 receive)
  #:use-module (json)
  #:use-module (rnrs bytevectors)
  #:use-module (web client)
  #:export (attachments/get
            attachments/list
            groups/create
            groups/list
            messages/receive
            messages/send))

(define* (make-url #:rest parts)
  (string-join parts "/"))

(define (u8json->scm u8)
  (json-string->scm (utf8->string u8)))

(define (signal-cli-get url)
  (receive (response body)
      (http-get url
                #:headers '((Content-Type . "application/json")
                            (Accept       . "application/json"))
                #:decode-body? #t)
    (u8json->scm body)))

(define (signal-cli-post url payload)
  (receive (response body)
      (http-post url
                 #:headers '((Content-Type . "application/json")
                             (Accept       . "application/json"))
                 #:body (scm->json-string payload)
                 #:decode-body? #t)
    (u8json->scm body)))

(define* (attachments/get server attachment-id)
  "Serve the attachment with the given id in bytevector form."

  (receive (response body)
      (http-get (make-url server "v1" "attachments" attachment-id))
    body))

(define* (attachments/list server)
  "List all downloaded attachments."
  (signal-cli-get (make-url server "v1" "attachments")))

(define* (groups/list server account #:optional groupid)
  "Retrieve details about groups associated with the account.
A group ID can be provided to restrict results to that group."

  (define url (if groupid
                  (make-url server "v1" "groups" account groupid)
                  (make-url server "v1" "groups" account)))
  (signal-cli-get url))

(define* (groups/create server account name description members)
  "Create a new group."
  (signal-cli-post (make-url server "v1" "groups" account)
                   (list (cons "description" description)
                         (cons "name" name)
                         (cons "members" (list->vector members)))))

(define* (messages/receive server account)
  "Receive new messages."
  (signal-cli-get (make-url server "v1" "receive" account)))

(define* (messages/send server account message recipients
                        #:key (attachments '()))
  "Send a message."
  (define recip-lst (if (list? recipients) recipients (list recipients)))

  (signal-cli-post (make-url server "v2" "send")
                   `( ("number" . ,account)
                      ("message" . ,message)
                      ("base64_attachements" . ,(list->vector attachments))
                      ("recipients" . ,(list->vector recip-lst)))))
