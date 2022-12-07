# WKD hash encoder ansibleplugin
# Thanks to
# - https://github.com/artisanofcode/python-zbase32
# - https://www.uriports.com/blog/setting-up-openpgp-web-key-directory/
# for the implementation
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)

import collections.abc
import math
import hashlib

__metaclass__ = type

DOCUMENTATION = r'''
  name: wkd_hash
  version_added: "1.0"
  short_description: Return a user ID encoded using GPG WKD
  description:
    - Return a hashed version of a user ID for a GPG Web keys directory
  positional: _input, query
  options:
    _input:
      description: String to encode
      type: str
      required: true
'''

EXAMPLES = r'''
    parts: '{{ "andre" | wkd_hash }}'
    # => "z1cybqqife1c333kqxqifnz64w9tb3xh"
'''

RETURN = r'''
  _value:
    description:
      - Compute a WKD hash from a user ID
    type: str
'''

from ansible.errors import AnsibleFilterError
from ansible.utils import helpers


def _chunks(buffer: bytearray, size: int) -> collections.abc.Generator[bytearray, None, None]:
    """
    chunks.
    :param buffer: the buffer to chunk
    :param size: the size of each chunk
    :return: an iterable of chunks
    """
    for i in range(0, len(buffer), size):
        yield buffer[i : i + size]


def wkd_hash_fn(input_str):

    _ALPHABET = b"ybndrfg8ejkmcpqxot1uwisza345h769"
    _INVERSE_ALPHABET = {key: value for value, key in enumerate(_ALPHABET)}

    # We should use string only on imput
    assert isinstance(input_str, str)

    # Encode using sha1sum
    hashed = hashlib.sha1(input_str.encode("utf-8"))

    # Convert to a byte array
    data = hashed.digest()

    result = bytearray()

    for chunk in _chunks(data, 5):

        buffer = bytearray(5)

        for index, byte in enumerate(chunk):
            buffer[index] = byte

        result.append(_ALPHABET[((buffer[0] & 0xF8) >> 3)])
        result.append(_ALPHABET[((buffer[0] & 0x07) << 2 | (buffer[1] & 0xC0) >> 6)])
        result.append(_ALPHABET[((buffer[1] & 0x3E) >> 1)])
        result.append(_ALPHABET[((buffer[1] & 0x01) << 4 | (buffer[2] & 0xF0) >> 4)])
        result.append(_ALPHABET[((buffer[2] & 0x0F) << 1 | (buffer[3] & 0x80) >> 7)])
        result.append(_ALPHABET[((buffer[3] & 0x7C) >> 2)])
        result.append(_ALPHABET[((buffer[3] & 0x03) << 3 | (buffer[4] & 0xE0) >> 5)])
        result.append(_ALPHABET[(buffer[4] & 0x1F)])

    length = math.ceil(len(data) * 8.0 / 5.0)

    return bytes(result[:length]).decode()


# ---- Ansible filters ----
class FilterModule(object):
    ''' WKD hash filter '''

    def filters(self):
        return {
            'wkd_hash': wkd_hash_fn
        }
