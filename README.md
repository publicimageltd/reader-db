# reader-db
Simple configuration data base for emacs lisp programs.

Provides a very simple database to store values associated with
distinct keys (called 'slots'). 

This is not a replacement for a real data base; it is mainly intented
to store simple configuration information.

The data is stored as a readable Lisp object. Thus, only printable
objects can be stored. All modifications of the data base rewrite
the complete file.

The data file has to be initialized with a *definition object* (an
alist) which defines the slots. The definition object can optionally provide
default values. See the variable ``reader-db-definition`` for an
example.

# Example usage:

```
;; Define the data base:
(setq db-definition '((slot1) (slot2)))

;; Initialize the database:
(reader-db-init "filename" db-definition)

;; Retrieve the value of slot1:
(reader-db-get "filename" 'slot1)      ;         =>  nil

;; Store a new value into slot1:
(reader-db-put  "filename" 'slot1 "new-value")

;; Retrieve the new value:
(reader-db-get "filename" 'slot1)      ;          => "new-value"
```


