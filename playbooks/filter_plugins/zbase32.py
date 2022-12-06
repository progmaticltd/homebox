# z-base32 encoder ansibleplugin
# See https://github.com/artisanofcode/python-zbase32 for a full implementation.
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

DOCUMENTATION = r'''
  name: zbase32encode
  version_added: "1.0"
  short_description: Encode a string using z-base32 scheme
  description:
    - Encode a string using z-base32 scheme
  positional: _input, query
  options:
    _input:
      description: String to encode
      type: str
      required: true
'''

EXAMPLES = r'''
    parts: '{{ "lovelace" | zbase32encode }}'
    # => "ptzzc3mccftsk"
'''

RETURN = r'''
  _value:
    description:
      - A z-base32 string from the input
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


def zbase32encode(data):

    _ALPHABET = b"ybndrfg8ejkmcpqxot1uwisza345h769"
    _INVERSE_ALPHABET = {key: value for value, key in enumerate(_ALPHABET)}

    data = str(data)

    assert isinstance(data, bytes)

    result = bytearray()

    for chunk in _chunks(bytearray(data), 5):

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
    ''' Z-Base32 simple filter '''

    def filters(self):
        return {
            'zbase32encode': zbase32encode
        }
