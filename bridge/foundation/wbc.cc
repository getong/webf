#include "wbc.h"
#include "logging.h"

namespace webf {
    bool Wbc::verifySignature(const uint8_t *bytes) {
        for (int i = 0; i < sizeof(Wbc::WBC_SIGNATURE); ++i) {
            if (bytes[i] != Wbc::WBC_SIGNATURE[i]) {
                return false;
            }
        }
        return true;
    }

    uint32_t Wbc::convertBigEndianToUint32(const uint8_t *bytes, size_t startIndex) {
        return ((uint32_t) bytes[startIndex] << 24) |
               ((uint32_t) bytes[startIndex + 1] << 16) |
               ((uint32_t) bytes[startIndex + 2] << 8) |
               (uint32_t) bytes[startIndex + 3];
    }

    uint32_t Wbc::calculateAdler32(const uint8_t *array, size_t len, uint32_t adler) {
        const uint32_t base = 65521; // largest prime smaller than 65536
        uint32_t s1 = adler & 0xffff;
        uint32_t s2 = adler >> 16;
        size_t i = 0;

        while (len > 0) {
            size_t n = 3800;
            if (n > len) {
                n = len;
            }
            len -= n;

            while (n-- > 0) {
                s1 = s1 + (array[i++] & 0xff);
                s2 = s2 + s1;
            }
            s1 %= base;
            s2 %= base;
        }

        return (s2 << 16) | s1;
    }

    // wbc file format
    // ┌────┬────┬────┬────┬────┬────┬────┬────┬────┐────────
    // │0x98│0x57│0x42│0x43│0x31│0x0D│0x0A│0x1A│0x0A│  Signature
    // ├────┴────┴────┴────┼────┴────┴────┴────┼────┤────────
    // │        Length     │    CHUNK_TYPE     │ M  │
    // ├────┬────┬─────────┴────┬──────────────┴────┤  Header
    // │ L  │ V  │      A       │   CRC32 CHECKSUM  │
    // ├────┴────┴─────────┬────┴──────────────┬────┤────────
    // │        Length     │    CHUNK_TYPE     │    │
    // ├───────────────────┴───────────────────┘    │
    // │                                            │
    // │                                            │
    // │                                            │
    // │                                            │
    // │                                            │  BODY
    // │              QuickJS ByteCode BODY         │
    // │                                            │
    // │                                            │
    // │                        ┌───────────────────┤
    // │                        │   CRC32 CHECKSUM  │
    // ├───────────────────┬────┴─────────────┬─────┘────────
    // │      Length       │    CHUNK_TYPE    │        END
    // └───────────────────┴──────────────────┘      ────────
    uint8_t * Wbc::prepareWbc(const uint8_t *bytes, size_t length, size_t *targetSize) {
        uint32_t signatureSize = sizeof(Wbc::WBC_SIGNATURE);
        if (length < signatureSize || !verifySignature(bytes)) {
            WEBF_LOG(ERROR) << "prepareWbc signatureSize is wrong" << std::endl;
            return nullptr;
        }

        // Extracting header length
        uint32_t headerLength = convertBigEndianToUint32(bytes, signatureSize);
        uint32_t bodyOffset = signatureSize + headerLength;
        uint32_t headerChecksumOffset = bodyOffset - Wbc::WBC_HEADER_CHECKSUM_LENGTH;

        // Calculating Adler32 checksum for header content
        uint32_t headerContentAdler32 = calculateAdler32(bytes + signatureSize,
                                                         headerChecksumOffset - signatureSize);
        uint32_t headerAdler32 = convertBigEndianToUint32(bytes, headerChecksumOffset);
        if (headerContentAdler32 != headerAdler32) {
            WEBF_LOG(ERROR) << "prepareWbc headerAdler32 is wrong" << std::endl;
            return nullptr;
        }

        // Extracting body length
        uint32_t bodyLength = convertBigEndianToUint32(bytes, bodyOffset);
        uint32_t bodyChecksumOffset = bodyOffset + bodyLength - Wbc::WBC_BODY_CHECKSUM_LENGTH;

        // Calculating Adler32 checksum for body content
        uint32_t bodyContentAdler32 = calculateAdler32(bytes + bodyOffset,
                                                       bodyChecksumOffset - bodyOffset);
        uint32_t bodyAdler32 = convertBigEndianToUint32(bytes, bodyChecksumOffset);
        if (bodyContentAdler32 != bodyAdler32) {
            WEBF_LOG(ERROR) << "prepareWbc bodyAdler32 is wrong" << std::endl;
            return nullptr;
        }

        uint32_t bodyChunkOffset =
                bodyOffset + Wbc::WBC_BODY_LENGTH + Wbc::WBC_BODY_CHUNK_TYPE_LENGTH;

        // Parsed according to the format of node-lz4
        // https://github.com/pierrec/node-lz4
        uint32_t dataBlockSizeOffset =
                bodyChunkOffset + Wbc::NODE_LZ4_MAGIC + Wbc::NODE_LZ4_DESCRIPTOR +
                Wbc::NODE_LZ4_DESCRIPTOR_CHECKSUM;
        uint32_t dataBlockOffset = dataBlockSizeOffset + Wbc::NODE_LZ4_DATABLOCK_SIZE;

        uint32_t dataBlockSize;
        memcpy(&dataBlockSize, &bytes[dataBlockSizeOffset], Wbc::NODE_LZ4_DATABLOCK_SIZE);
        *targetSize = dataBlockSize;

        auto *dataBlockBytes = (uint8_t *) malloc(dataBlockSize);
        if (!dataBlockBytes) {
            WEBF_LOG(ERROR) << "prepareWbc malloc dataBlockBytes failed!" << std::endl;
            return nullptr;
        }

        memcpy(dataBlockBytes, bytes + dataBlockOffset, dataBlockSize);

        return dataBlockBytes;
    }

}  // namespace webf
