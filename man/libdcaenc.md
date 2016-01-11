% LIBDCANEC(3)
% Alexander E. Patrakov <patrakov@gmail.com>
% September, 2014

NAME
====

libdcaenc - encoding library for the DTS Coherent Acoustics audio format

DESCRIPTION
===========

**libdcaenc** is an open-source implementation of the DTS Coherent Acoustics
lossy audio codec.  Only the core part of the encoder is implemented,
even though the full specification (ETSI TS 102 114 V1.3.1) is available
for download.

The libdcaenc library
=====================

The library may be useful if you want to create DTS streams in your own
UNIX application.

To do so, you have to call the following functions:

	dcaenc_context dcaenc_create(
		int sample_rate,
		int channel_config,
		int approx_bitrate,
		int flags);

This function creates a library context according to its parameters. The
resulting context is an opaque value that should be passed to the other library
functions as the first parameter.

The sample rate must be one of the following values: 32000, 44100, 48000 or
those divided by 2 or 4. The channel configuration is one of the
**DCAENC_CHANNELS_*** defines listed in the dcaenc.h header. Note that values
greater than **DCAENC_CHANNELS_3FRONT_2REAR** always return an error now because
their encoding requires the XCH/XXCH extensions that became documented only in
September 2011 and thus were not implemented. Only non-LFE channels have to be
specified here. The approximate bitrate is specified in bits per second and
may be rounded slightly up or down by the library.

The flags parameter should be a logical OR of zero or more of the
**DCAENC_FLAG_*** defines. Their meanings:

DCAENC_FLAG_28BIT
:	use only 28 out of 32 bits in each four bytes of output. This may be useful if the loudness of the hiss resulting from mis-interpretation of the encoded stream as PCM must be reduced. However, this also results in the reduction of the effective bitrate by 12.5%. DTS CDs are usually encoded with this option.

DCAENC_FLAG_BIGENDIAN
:	produce a big-endian variant of the DTS bitstream. This may be useful for writing the stream as a DVD sound track.

DCAENC_FLAG_LFE
:	indicates that a separate LFE channel has to be added to the layout indicated by the channel_config parameter.

DCAENC_FLAG_PERFECT_QMF
:	selects a "perfect-reconstruction" version of the quadrature mirror filter. This reduces distortions inherent in the filterbank design, but makes the filter output more sensitive to quantization errors introduced later in the encoder. libdca version 0.0.5 or earlier will not be able to decode the resulting stream correctly due to a bug (mistyped table) in it. It makes no sense to use this option for streams with bitrate of 0.3 Mbps per channel or less.

DCAENC_FLAG_IEC_WRAP
:	wraps DTS frames as defined by the IEC 61937-5 standard for transmission over SPDIF. Namely, the library adds a 8-byte header to each frame and pads the frame with zeroes to achieve the same bitrate as a stereo 16-bit PCM stream.

On any error, **dcaenc_create()** returns NULL. There is no way to find out the
reason for the error.

int dcaenc_channel_config_to_count(int channel_config);
:	Returns the number of channels used in a given channel configuration, or -1	if the channel configuration is invalid or unsupported.

int dcaenc_bitrate(dcaenc_context c);
:	Returns the actual bitrate that is used by the library.

int dcaenc_input_size(dcaenc_context c);
:	Returns the size of the input buffer that your application has to submit, in samples. Now this value is always equal to 512.

int dcaenc_output_size(dcaenc_context c);
:	Returns the size of the output buffer that the application should provide, in bytes.


int dcaenc_convert_s32(
:	**dcaenc_context c,**

	**const int32_t \*input,**

	**uint8_t \*output);**

Performs the conversion of PCM samples stored in the input buffer to the DTS bitstream, stores one frame of the encoded bitstream in the output buffer. The input buffer should contain interleaved signed 32-bit samples. The channel order is as follows:

	DCAENC_CHANNELS_MONO: center
	DCAENC_CHANNELS_STEREO: left, right
	DCAENC_CHANNELS_3FRONT: center, left, right
	DCAENC_CHANNELS_2FRONT_1REAR: left, right, surround
	DCAENC_CHANNELS_3FRONT_1REAR: center, left, right, surround
	DCAENC_CHANNELS_2FRONT_2REAR: left, right, surround left, surround right
	DCAENC_CHANNELS_3FRONT_2REAR: center, left, right, surround left, surround right

If the LFE channel is used, it should be added as the last one.

The following layouts are also defined and do not return an error while
encoding, but do not result in a high-quality bitstream due to incompatibility
with the psychoacoustical model used by the library:

	DCAENC_CHANNELS_DUAL_MONO: A, B
	DCAENC_CHANNELS_STEREO_SUMDIFF: left+right, left-right
	DCAENC_CHANNELS_STEREO_TOTAL: left total, right total

Unfortunately, there is currently no API to query the order of channels by the
channel layout. This is because it is unclear what functionality related to
channel mapping should be exposed. E.g., should speaker IDs compatible
with ksmedia.h (as used in Windows and in WAVEFORMATEXTENSIBLE wav files) be
used, even though a mapping between these speaker IDs and the positions used
in the DTS specification is in some cases only approximate (e.g., there is no
"Surround Left 2" speaker in ksmedia.h). Please mail your suggestions
regarding this API to *<patrakov@gmail.com>*.

**dcaenc_convert_s32()** returns the number of bytes written to the output buffer.
Right now, it is always the same as returned by dcaenc_output_size(), but
this will change if variable bitrate encoding is added to the library.

int dcaenc_destroy(dcaenc_context c, uint8_t *output);

:	Destroys the library context. If a non-NULL value is provided in the output parameter, the library encodes the final frame and puts it there. This may be useful because there is a 512-sample latency inherent in the DTS filterbank, so the output frame gets the last portion of the PCM input submitted earlier. The returned value indicates the number of bytes written to the output buffer.

SEE ALSO
========

**dcaenc**(1)
