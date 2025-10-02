# utils.py
import re
import unicodedata
from typing import Optional, Tuple

_PERSIAN_DIGITS = "۰۱۲۳۴۵۶۷۸۹"
_ARABIC_DIGITS  = "٠١٢٣٤٥٦٧٨٩"
_EN_DIGITS      = "0123456789"

_TRANSLATION_TABLE = {
    **{ord(fa): ord(en) for fa, en in zip(_PERSIAN_DIGITS, _EN_DIGITS)},
    **{ord(ar): ord(en) for ar, en in zip(_ARABIC_DIGITS, _EN_DIGITS)},
    ord("\u066B"): ord("."),
    ord("\u066C"): ord(","),
}


_RTL_MARKS_PATTERN = re.compile(r"[\u200c\u200e\u200f]")

def to_english_digits(value: Optional[str]) -> str:

    if value is None:
        return ""
    s = unicodedata.normalize("NFKC", str(value))
    s = s.translate(_TRANSLATION_TABLE)
    s = _RTL_MARKS_PATTERN.sub("", s)
    return s

def normalize_phone_and_code(phone: str, code: str) -> Tuple[str, str]:

    p = to_english_digits(phone).strip()

    if p.startswith("+"):
        p = "+" + re.sub(r"[\s\-\u2010-\u2015\u2212_]", "", p[1:])
    else:
        p = re.sub(r"[\s\-\u2010-\u2015\u2212_]", "", p)

    c = to_english_digits(code).strip()
    return p, c
