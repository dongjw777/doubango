
/*
* Copyright (C) 2009 Mamadou Diop.
*
* Contact: Mamadou Diop <diopmamadou@yahoo.fr>
*	
* This file is part of Open Source Doubango Framework.
*
* DOUBANGO is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*	
* DOUBANGO is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*	
* You should have received a copy of the GNU General Public License
* along with DOUBANGO.
*
*/

/**@file tsip_header_Proxy_Require.c
 * @brief SIP Proxy-Require header.
 *
 * @author Mamadou Diop <diopmamadou(at)yahoo.fr>
 *
 * @date Created: Sat Nov 8 16:54:58 2009 mdiop
 */
#include "tinySIP/headers/tsip_header_Proxy_Require.h"

#include "tinySIP/parsers/tsip_parser_uri.h"

#include "tsk_debug.h"
#include "tsk_memory.h"

#include <string.h>

/**@defgroup tsip_header_Proxy_Require_group SIP Proxy_Require header.
*/

/***********************************
*	Ragel state machine.
*/
%%{
	machine tsip_machine_parser_header_Proxy_Require;

	# Includes
	include tsip_machine_utils "./tsip_machine_utils.rl";
	
	action tag
	{
		tag_start = p;
	}
	
	action parse_option
	{
		TSK_PARSER_ADD_STRING(hdr_proxyrequire->options);
	}

	action eob
	{
	}
	
	Proxy_Require = "Proxy-Require"i HCOLON option_tag>tag %parse_option ( COMMA option_tag>tag %parse_option )*;
	
	# Entry point
	main := Proxy_Require :>CRLF @eob;

}%%

int tsip_header_Proxy_Require_tostring(const void* header, tsk_buffer_t* output)
{
	if(header)
	{
		const tsip_header_Proxy_Require_t *Proxy_Require = header;
		tsk_list_item_t *item;
		tsk_string_t *str;
		int ret = 0;

		tsk_list_foreach(item, Proxy_Require->options)
		{
			str = item->data;
			if(item == Proxy_Require->options->head)
			{
				tsk_buffer_append(output, str->value, strlen(str->value));
			}
			else
			{
				tsk_buffer_appendEx(output, ",%s", str->value);
			}
		}

		return ret;
	}

	return -1;
}

tsip_header_Proxy_Require_t *tsip_header_Proxy_Require_parse(const char *data, size_t size)
{
	int cs = 0;
	const char *p = data;
	const char *pe = p + size;
	const char *eof = pe;
	tsip_header_Proxy_Require_t *hdr_proxyrequire = TSIP_HEADER_PROXY_REQUIRE_CREATE_NULL();
	
	const char *tag_start;

	%%write data;
	%%write init;
	%%write exec;
	
	if( cs < %%{ write first_final; }%% )
	{
		TSK_OBJECT_SAFE_FREE(hdr_proxyrequire);
	}
	
	return hdr_proxyrequire;
}







//========================================================
//	Proxy_Require header object definition
//

static void* tsip_header_Proxy_Require_create(void *self, va_list * app)
{
	tsip_header_Proxy_Require_t *Proxy_Require = self;
	if(Proxy_Require)
	{
		const char* option;

		TSIP_HEADER(Proxy_Require)->type = tsip_htype_Proxy_Require;
		TSIP_HEADER(Proxy_Require)->tostring = tsip_header_Proxy_Require_tostring;

		if((option = va_arg(*app, const char*))){
			tsk_string_t* string = TSK_STRING_CREATE(option);
			Proxy_Require->options = TSK_LIST_CREATE();

			tsk_list_push_back_data(Proxy_Require->options, ((void**) &string));
		}
	}
	else
	{
		TSK_DEBUG_ERROR("Failed to create new Proxy_Require header.");
	}
	return self;
}

static void* tsip_header_Proxy_Require_destroy(void *self)
{
	tsip_header_Proxy_Require_t *Proxy_Require = self;
	if(Proxy_Require)
	{
		TSK_OBJECT_SAFE_FREE(Proxy_Require->options);
	}
	else TSK_DEBUG_ERROR("Null Proxy_Require header.");

	return self;
}

static const tsk_object_def_t tsip_header_Proxy_Require_def_s = 
{
	sizeof(tsip_header_Proxy_Require_t),
	tsip_header_Proxy_Require_create,
	tsip_header_Proxy_Require_destroy,
	0
};
const void *tsip_header_Proxy_Require_def_t = &tsip_header_Proxy_Require_def_s;