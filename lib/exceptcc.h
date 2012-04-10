/*
Copyright (C) 2011, 2012 Mark Veltzer, <mark.veltzer@gmail.com>,
	All Rights Reserved.

You are free to distribute this software under Version 2.1
of the GNU Lesser General Public License.
On Debian systems, refer to /usr/share/common-licenses/LGPL-2.1
for the complete text of the GNU Lesser General Public License.

Certain components (as annotated in the source) are licensed
under the terms of the GNU General Public License.
On Debian systems, the complete text of the GNU General Public
License can be found in /usr/share/common-licenses/GPL file.
*/

#ifndef __exceptcc_h
#define __exceptcc_h

#ifdef __cplusplus
extern "C" {
#endif
	void except_throw(const char*);
#ifdef __cplusplus
};
#endif

#endif /* __exceptcc_h */
