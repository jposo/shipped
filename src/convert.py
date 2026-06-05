import argparse
import base64
import gzip
import zlib


# https://wyliemaster.github.io/gddocs/#/topics/levelstring_encoding_decoding
def decode_level(level_data: str, is_official_level: bool):
    if is_official_level:
        level_data = "H4sIAAAAAAAAA" + level_data
    base64_decoded = base64.urlsafe_b64decode(level_data.encode())
    decompressed = zlib.decompress(base64_decoded, 15 | 32)
    return decompressed.decode()


def encode_level(level_string: str, is_official_level: bool):
    gzipped = gzip.compress(level_string.encode())
    base64_encoded = base64.urlsafe_b64encode(gzipped)
    if is_official_level:
        base64_encoded = base64_encoded[13:]
    return base64_encoded.decode()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "mode",
        choices=["encode", "decode"],
        help="Choose whether to decode or encode level data",
    )
    parser.add_argument("level_data", help="Raw level data string")
    parser.add_argument(
        "-o", "--official", action="store_true", help="Level is an official level"
    )

    args = parser.parse_args()

    if args.mode == "decode":
        str = decode_level(args.level_data, args.official)
    else:
        str = encode_level(args.level_data, args.official)
    print(str)


if __name__ == "__main__":
    main()
