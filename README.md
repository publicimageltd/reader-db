# reader-db
Simple configuration data base for emacs lisp programs.

Provides a very simple database to store values associated with
distinct keys (called 'slots'). 

This is not a replacement for a real data base; it is mainly intented to store simple configuration
information.

The data is stored as a readable Lisp object. Thus, only printable
objects can be stored. All modifications of the data base rewrite
the complete file.

The data file has to be initialized with a *definition object* (an
alist) which defines the slots. The definition object can optionally provide
default values. See the variable ``reader-db-definition`` for an
example.

# Example usage:

```
(setq db-definition '((slot1) (slot2)))
(reader-db-init "filename" db-definition)
(reader-db-get "filename" 'slot1)      ;         =>  nil
(reader-db-put  "filename" 'slot1 "new-value")
(reader-db-get "filename" 'slot1)      ;          => "new-value"
```
