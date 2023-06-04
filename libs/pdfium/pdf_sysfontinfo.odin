package pdfium

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/pdfium.dll.lib"
} else {
	foreign import lib "system:pdfium"
}

/* Character sets for the font */
FXFONT_ANSI_CHARSET :: 0
FXFONT_DEFAULT_CHARSET :: 1
FXFONT_SYMBOL_CHARSET :: 2
FXFONT_SHIFTJIS_CHARSET :: 128
FXFONT_HANGEUL_CHARSET :: 129
FXFONT_GB2312_CHARSET :: 134
FXFONT_CHINESEBIG5_CHARSET :: 136
FXFONT_GREEK_CHARSET :: 161
FXFONT_VIETNAMESE_CHARSET :: 163
FXFONT_HEBREW_CHARSET :: 177
FXFONT_ARABIC_CHARSET :: 178
FXFONT_CYRILLIC_CHARSET :: 204
FXFONT_THAI_CHARSET :: 222
FXFONT_EASTERNEUROPEAN_CHARSET :: 238

/* Font pitch and family flags */
FXFONT_FF_FIXEDPITCH :: (1 << 0)
FXFONT_FF_ROMAN :: (1 << 4)
FXFONT_FF_SCRIPT :: (4 << 4)

/* Typical weight values */
FXFONT_FW_NORMAL :: 400
FXFONT_FW_BOLD :: 700

/*
 * Interface: FPDF_SYSFONTINFO
 *          Interface for getting system font information and font mapping
 */
SYSFONTINFO :: struct {
	/*
   * Version number of the interface. Currently must be 1.
   */
	version:        c.int,

	/*
   * Method: Release
   *          Give implementation a chance to release any data after the
   *          interface is no longer used.
   * Interface Version:
   *          1
   * Implementation Required:
   *          No
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   * Return Value:
   *          None
   * Comments:
   *          Called by PDFium during the final cleanup process.
   */
	Release:        proc(pThis: ^SYSFONTINFO),

	/*
   * Method: EnumFonts
   *          Enumerate all fonts installed on the system
   * Interface Version:
   *          1
   * Implementation Required:
   *          No
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          pMapper     -   An opaque pointer to internal font mapper, used
   *                          when calling FPDF_AddInstalledFont().
   * Return Value:
   *          None
   * Comments:
   *          Implementations should call FPDF_AddIntalledFont() function for
   *          each font found. Only TrueType/OpenType and Type1 fonts are accepted
   *          by PDFium.
   */
	EnumFonts:      proc(pThis: ^SYSFONTINFO, pMapper: rawptr),

	/*
   * Method: MapFont
   *          Use the system font mapper to get a font handle from requested
   *          parameters.
   * Interface Version:
   *          1
   * Implementation Required:
   *          Required if GetFont method is not implemented.
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          weight      -   Weight of the requested font. 400 is normal and
   *                          700 is bold.
   *          bItalic     -   Italic option of the requested font, TRUE or
   *                          FALSE.
   *          charset     -   Character set identifier for the requested font.
   *                          See above defined constants.
   *          pitch_family -  A combination of flags. See above defined
   *                          constants.
   *          face        -   Typeface name. Currently use system local encoding
   *                          only.
   *          bExact      -   Obsolete: this parameter is now ignored.
   * Return Value:
   *          An opaque pointer for font handle, or NULL if system mapping is
   *          not supported.
   * Comments:
   *          If the system supports native font mapper (like Windows),
   *          implementation can implement this method to get a font handle.
   *          Otherwise, PDFium will do the mapping and then call GetFont
   *          method. Only TrueType/OpenType and Type1 fonts are accepted
   *          by PDFium.
   */
	MapFont:        proc(
		pThis: ^SYSFONTINFO,
		weight: c.int,
		bItalic: BOOL,
		charset: c.int,
		pitch_family: c.int,
		face: cstring,
		bExact: ^BOOL,
	) -> rawptr,

	/*
   * Method: GetFont
   *          Get a handle to a particular font by its internal ID
   * Interface Version:
   *          1
   * Implementation Required:
   *          Required if MapFont method is not implemented.
   * Return Value:
   *          An opaque pointer for font handle.
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          face        -   Typeface name in system local encoding.
   * Comments:
   *          If the system mapping not supported, PDFium will do the font
   *          mapping and use this method to get a font handle.
   */
	GetFont:        proc(pThis: ^SYSFONTINFO, face: cstring) -> rawptr,

	/*
   * Method: GetFontData
   *          Get font data from a font
   * Interface Version:
   *          1
   * Implementation Required:
   *          Yes
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          hFont       -   Font handle returned by MapFont or GetFont method
   *          table       -   TrueType/OpenType table identifier (refer to
   *                          TrueType specification), or 0 for the whole file.
   *          buffer      -   The buffer receiving the font data. Can be NULL if
   *                          not provided.
   *          buf_size    -   Buffer size, can be zero if not provided.
   * Return Value:
   *          Number of bytes needed, if buffer not provided or not large
   *          enough, or number of bytes written into buffer otherwise.
   * Comments:
   *          Can read either the full font file, or a particular
   *          TrueType/OpenType table.
   */
	GetFontData:    proc(
		pThis: ^SYSFONTINFO,
		hFont: rawptr,
		table: c.uint,
		buffer: ^c.uchar,
		buf_size: c.ulong,
	) -> c.ulong,

	/*
   * Method: GetFaceName
   *          Get face name from a font handle
   * Interface Version:
   *          1
   * Implementation Required:
   *          No
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          hFont       -   Font handle returned by MapFont or GetFont method
   *          buffer      -   The buffer receiving the face name. Can be NULL if
   *                          not provided
   *          buf_size    -   Buffer size, can be zero if not provided
   * Return Value:
   *          Number of bytes needed, if buffer not provided or not large
   *          enough, or number of bytes written into buffer otherwise.
   */
	GetFaceName:    proc(pThis: ^SYSFONTINFO, hFont: rawptr, buffer: cstring, buf_size: c.ulong) -> c.ulong,

	/*
   * Method: GetFontCharset
   *          Get character set information for a font handle
   * Interface Version:
   *          1
   * Implementation Required:
   *          No
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          hFont       -   Font handle returned by MapFont or GetFont method
   * Return Value:
   *          Character set identifier. See defined constants above.
   */
	GetFontCharset: proc(pThis: ^SYSFONTINFO, hFont: rawptr) -> c.int,

	/*
   * Method: DeleteFont
   *          Delete a font handle
   * Interface Version:
   *          1
   * Implementation Required:
   *          Yes
   * Parameters:
   *          pThis       -   Pointer to the interface structure itself
   *          hFont       -   Font handle returned by MapFont or GetFont method
   * Return Value:
   *          None
   */
	DeleteFont:     proc(pThis: ^SYSFONTINFO, hFont: rawptr),
}

/*
 * Struct: FPDF_CharsetFontMap
 *    Provides the name of a font to use for a given charset value.
 */
CharsetFontMap :: struct {
	charset:  c.int, // Character Set Enum value, see FXFONT_*_CHARSET above.
	fontname: cstring, // Name of default font to use with that charset.
}
