; HTML Utils. 


(def color (r g b)
  (with (c (table) 
         f (fn (x) (if (< x 0) 0 (> x 255) 255 x)))
    (= (c 'r) (f r) (c 'g) (f g) (c 'b) (f b))
    c))

(def dehex (str) (errsafe (coerce str 'int 16)))

(defmemo hex>color (str)
  (and (is (len str) 6)
       (with (r (dehex (cut str 0 2))
              g (dehex (cut str 2 4))
              b (dehex (cut str 4 6)))
         (and r g b
              (color r g b)))))

(defmemo gray (n) (color n n n))

(= white    (gray 255) 
   black    (gray 0)
   linkblue (color 0 0 190)
   orange   (color 255 102 0)
   )

(= opmeths* (table))

; hack: intern key pair till have implicit tables of tables

(mac opmeth (tag opt)
  (w/uniq o-v
    `(let ,o-v (string ,opt)
       (or (opmeths* (sym (+ (string ,tag) "."  ,o-v)))
           (opmeths* (sym (+ "*."  ,o-v)))))))

(mac attribute (tag opt f)
; `(= (opmeth ',tag ',opt) ,f)
  `(= (opmeths* ',(sym (+ (string tag) "."  (string opt))))
      ,f))

(= hexreps (table))

(for i 0 255 (= (hexreps i)
                (let s (coerce i 'string 16)
                  (if (is (len s) 1) (+ "0" s) s))))

(defmemo hexrep (col)
  (+ (hexreps (col 'r)) (hexreps (col 'g)) (hexreps (col 'b))))

(def opcolor (key val) 
  (w/uniq gv
    `(whenlet ,gv ,val
       (pr " " ',key "=#" (hexrep ,gv)))))

(def opstring (key val)
  `(aif ,val (pr " " ',key "=\"" it #\")))

(def opnum (key val)
  `(aif ,val (pr " " ',key "=" it)))

(def opsym (key val)
  `(pr " " ',key "=" ,val))

(def opsel (key val)
  `(if ,val (pr " selected")))

(def opesc (key val)
  `(awhen ,val
     (pr " " ',key "=\"")
     (if (isa it 'string) (pr-escaped it) (pr it))
     (pr  #\")))

; need to escape more?  =?

(def pr-escaped (x)
  (each c x 
    (pr (case c #\<  "&#60;"  
                #\>  "&#62;"  
                #\"  "&#34;"  
                #\&  "&#38;"
                c))))

(attribute *          class          opstring)
(attribute *          id             opstring)
(attribute *          style          opstring)
(attribute a          href           opstring)
(attribute a          rel            opstring)
(attribute a          onclick        opstring)
(attribute body       alink          opcolor)
(attribute body       bgcolor        opcolor)
(attribute body       leftmargin     opnum)
(attribute body       link           opcolor)
(attribute body       marginheight   opnum)
(attribute body       marginwidth    opnum)
(attribute body       topmargin      opnum)
(attribute body       vlink          opcolor)
(attribute div        align          opsym)
(attribute div        dir            opsym)
(attribute div        lang           opstring)
(attribute div        onclick        opstring)
(attribute div        style          opstring)
(attribute div        title          opstring)
(attribute feed       xmlns          opstring)
(attribute font       color          opcolor)
(attribute font       face           opstring)
(attribute font       size           opnum)
(attribute form       action         opstring)
(attribute form       method         opsym)
(attribute html       lang           opstring)
(attribute html       xml:lang       opstring)
(attribute html       xmlns          opstring)
(attribute img        align          opsym)
(attribute img        alt            opstring)
(attribute img        border         opnum)
(attribute img        height         opnum)
(attribute img        width          opnum)
(attribute img        vspace         opnum)
(attribute img        hspace         opnum)
(attribute img        src            opstring)
(attribute input      name           opstring)
(attribute input      size           opnum)
(attribute input      type           opsym)
(attribute input      value          opesc)
(attribute link       href           opstring)
(attribute link       rel            opstring)
(attribute link       type           opsym)
(attribute meta       charset        opstring)
(attribute meta       content        opsym)
(attribute meta       http-equive    opsym)
(attribute option     selected       opsel)
(attribute option     value          opstring)
(attribute select     name           opstring)
(attribute table      bgcolor        opcolor)
(attribute table      border         opnum)
(attribute table      cellpadding    opnum)
(attribute table      cellspacing    opnum)
(attribute table      width          opstring)
(attribute textarea   cols           opnum)
(attribute textarea   name           opstring)
(attribute textarea   rows           opnum)
(attribute textarea   wrap           opsym)
(attribute td         align          opsym)
(attribute td         bgcolor        opcolor)
(attribute td         colspan        opnum)
(attribute td         width          opnum)
(attribute td         valign         opsym)
(attribute tr         bgcolor        opcolor)
(attribute hr         color          opcolor)
(attribute span       align          opstring)
(attribute rss        version        opstring)


(mac gentag args (start-tag args))
     
(mac tag (spec . body)
  `(do ,(start-tag spec)
       ,@body
       ,(end-tag spec)))

(mac empty-elem-tag spec
  `(do (pr "<" ',(car spec))
       ,@(tag-options (car spec) (pair (cdr spec)))
       (pr " />")))

(mac tag-if (test spec . body)
  `(if ,test
       (tag ,spec ,@body)
       (do ,@body)))

(def start-tag (spec)
  (if (atom spec)
      `(pr "<" ',spec ">")
      `(do (pr "<" ',(car spec))
           ,@(tag-options (car spec) (pair (cdr spec)))
           (pr ">"))))
        
(def end-tag (spec)
  `(pr "</" ',(carif spec) ">"))

(def tag-options (spec options)
  (if (no options)
      '()
      (let ((opt val) . rest) options
        (let meth (opmeth spec opt)
          (if meth
              (if val
                  (cons (meth opt val)
                        (tag-options spec rest))
                  (tag-options spec rest))
              (do
                (pr "<!-- ignoring " opt " for " spec "-->")
                (tag-options spec rest)))))))

(def br ((o n 1)) 
  (repeat n (pr "<br>")) 
  (prn))

(def br2 () (prn "<br><br>"))

(mac center    body         `(tag center ,@body))
(mac underline body         `(tag u ,@body))
(mac tab       body         `(tag (table border 0) ,@body))
(mac tr        body         `(tag tr ,@body))

(let pratoms (fn (body)
               (if (or (no body) 
                       (all [and (acons _) (isnt (car _) 'quote)]
                            body))
                   body
                   `((pr ,@body))))

  (mac td       body         `(tag td ,@(pratoms body)))
  (mac trtd     body         `(tr (td ,@(pratoms body))))
  (mac tdright  body         `(tag (td align 'right) ,@(pratoms body)))
  (mac tdcolor  (col . body) `(tag (td bgcolor ,col) ,@(pratoms body)))
)

(mac row args
  `(tr ,@(map [list 'td _] args)))

(mac prrow args
  (w/uniq g
    `(tr ,@(map (fn (a) 
                  `(let ,g ,a
                     (if (number ,g)
                         (tdright (pr ,g))
                         (td (pr ,g)))))
                 args))))

(mac prbold body `(tag b (pr ,@body)))

(def para args 
  (gentag p)
  (when args (apply pr args)))

(def menu (name items (o sel nil))
  (tag (select name name)
    (each i items
      (let (v txt) (if (acons i) i (list i i))
        (tag (option value v selected (is v sel))
          (pr txt))))))

(mac whitepage body
  `(tag html 
     (tag (body bgcolor white alink linkblue) ,@body)))

(def errpage args (whitepage (apply prn args)))

(def blank-url () "s.gif")

; Could memoize these.

; If h = 0, doesn't affect table column widths in some Netscapes.

(def hspace (n)    (gentag img src (blank-url) height 1 width n))
(def vspace (n)    (gentag img src (blank-url) height n width 0))
(def vhspace (h w) (gentag img src (blank-url) height h width w))

(mac new-hspace (n)    
  (if (number n)
      `(pr ,(string "<span style=\"padding-left:" n "px\" />"))
      `(pr "<span style=\"padding-left:" ,n "px\" />")))

;(def spacerow (h) (tr (td (vspace h))))

(def spacerow (h) (pr "<tr style=\"height:" h "px\"></tr>"))

; For use as nested table.

(mac zerotable body
  `(tag (table border 0 cellpadding 0 cellspacing 0)
     ,@body))

(mac sptab body
  `(tag (table border 0 cellpadding 0 cellspacing 7) ,@body))

(mac widtable (w . body)
  `(tag (table width ,w) (tr (td ,@body))))

(def cellpr (x) (pr (or x "&nbsp;")))

(def but ((o text "submit") (o name nil))
  (gentag input type 'submit name name value text))

(def submit ((o val "submit"))
  (gentag input type 'submit value val))

(def buts (name . texts)
  (if (no texts)
      (but)
      (do (but (car texts) name)
          (each text (cdr texts)
            (pr " ")
            (but text name)))))

(mac spanrow (n . body)
  `(tr (tag (td colspan ,n) ,@body)))

(mac form (action . body)
  `(tag (form method "post" action ,action) ,@body))

(mac textarea (name rows cols . body)
  `(tag (textarea name ,name rows ,rows cols ,cols) ,@body))

(def input (name (o val "") (o size 10))
  (gentag input type 'text name name value val size size))

(mac inputs args
  `(tag (table border 0)
     ,@(map (fn ((name label len text))
              (w/uniq (gl gt)
                `(let ,gl ,len
                   (tr (td (pr ',label ":"))
                       (if (isa ,gl 'cons)
                           (td (textarea ',name (car ,gl) (cadr ,gl)
                                 (let ,gt ,text (if ,gt (pr ,gt)))))
                           (td (gentag input type ',(if (is label 'password) 
                                                    'password 
                                                    'text)
                                         name ',name 
                                         size ,len 
                                         value ,text)))))))
            (tuples args 4))))

(def single-input (label name chars btext (o pwd))
  (pr label)
  (gentag input type (if pwd 'password 'text) name name size chars)
  (sp)
  (submit btext))

(mac cdata body
  `(do (pr "<![CDATA[") 
       ,@body
       (pr "]]>")))

(def eschtml (str)
  (tostring 
    (each c str
      (pr (case c #\<  "&#60;" 
                  #\>  "&#62;"
                  #\"  "&#34;"
                  #\'  "&#39;"
                  #\&  "&#38;"
                        c)))))

(def esc<>& (str)
  (tostring 
    (each c str
      (pr (case c #\<  "&#60;" 
                  #\>  "&#62;"
                  #\&  "&#38;"
                        c)))))

(def nbsp () (pr "&nbsp;"))

(def link (text (o dest text) (o color))
  (tag (a href dest) 
    (tag-if color (font color color)
      (pr text))))

(def underlink (text (o dest text))
  (tag (a href dest) (tag u (pr text))))

(def striptags (s)
  (let intag nil
    (tostring
      (each c s
        (if (is c #\<) (assert intag)
            (is c #\>) (wipe intag)
            (no intag) (pr c))))))

(def shortlink (url)
  (unless (or (no url) (< (len url) 7))
    (link (cut url 7) url)))

; this should be one regexp

(def parafy (str)
  (let ink nil
    (tostring
      (each c str
        (pr c)
        (unless (whitec c) (assert ink))
        (when (is c #\newline)
          (unless ink (pr "<p>"))
          (wipe ink))))))

(mac spanclass (name . body)
  `(tag (span class ',name) ,@body))

(mac div (args . body)
  `(tag (div ,@args) ,@body))

(mac divclass (name . body)
  `(tag (div class ',name) ,@body))

(def pagemessage (text)
  (when text (prn text) (br2)))

(mac doctype args
  `(prn (apply doctype-str ',args)))

(def doctype-str ((o name 'xhtml) (o version) (o type))
  (case name
    html
    (case type
      strict   "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"
      frameset "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">"
      "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">")
    xhtml
    (case version
      1.1 "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
      (case type
        strict       "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
        frameset     "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">"
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"))
    (err "Undefined doctype" name)))
