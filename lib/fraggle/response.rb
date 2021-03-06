require 'fraggle/msg'

##
# An extension to Response in msg.rb. I want to keep these seperated so when
# future versions of Beefcake can generate code, we don't have to manually add
# this back in for each generation.

module Fraggle

  class Response

    Missing =  0
    Clobber = -1
    Dir     = -2
    Dummy   = -3

    Refused = -1

    # CAS
    def missing?  ; cas == Missing ; end
    def dir?      ; cas == Dir     ; end
    def dummy?    ; cas == Dummy   ; end

    def del?      ; missing?       ; end
    def set?      ; !del?          ; end

    # ERR
    def ok?           ; err_code != 0                 ; end
    def other?        ; err_code == Err::OTHER        ; end
    def unknown_verb? ; err_code == Err::UNKNOWN_VERB ; end
    def redirect?     ; err_code == Err::REDIRECT     ; end
    def invalid_snap? ; err_code == Err::INVALID_SNAP ; end
    def mismatch?     ; err_code == Err::CAS_MISMATCH ; end
    def not_dir?      ; err_code == Err::NOT_DIR      ; end
    def is_dir?       ; err_code == Err::ISDIR        ; end

    # Custom
    def disconnected? ; err_code == Errno::ECONNREFUSED::Errno ; end
  end

end
