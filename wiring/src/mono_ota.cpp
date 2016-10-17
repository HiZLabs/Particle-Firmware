#include "spark_wiring_tcpclient.h"
#include "logging.h"
#include <stdlib.h>
#include "spark_wiring.h"
#include "spi_flash.h"

struct uri_t {
	String protocol;
	String host;
	uint16_t port;
	String resource;
};

bool stringToUri(uri_t& uriOut, String uriString)
{
	String temp = uriString;
	int idx = temp.indexOf("://");
	if(idx < 0) return false;
	uriOut.protocol = temp.substring(0, idx);
	temp = temp.substring(idx+3);
	idx = temp.indexOf("/");
	int idx2 = temp.indexOf(":");

	if(idx > 0 && idx2 == -1) //no colon with slash : idx > 0, idx2 == -1
	{
		uriOut.host = temp.substring(0, idx);
		uriOut.port = 0;
		uriOut.resource = temp.substring(idx).trim();
		return true;
	}
	else if(idx2 > 0 && idx > idx2) //colon before slash  : idx2 > 0, idx > idx2
	{
		uriOut.host = temp.substring(0, idx2);
		uriOut.port = temp.substring(idx2, idx).toInt();
		uriOut.resource = temp.substring(idx).trim();
		return true;
	}
	else if(idx == -1 && idx2 > idx) //colon with no slash : idx == -1, idx2 > idx
	{
		uriOut.host = temp.substring(0, idx2);
		uriOut.port = temp.substring(idx2).toInt();
		uriOut.resource = "";
		return true;
	}

	return false;
}

int ota(String url) {

	LOG_CATEGORY("app.ota");
	LOG(INFO, "Command received. Firmware: %s", url.c_str());
//	return 0;
#if 1
	const size_t bufferSize = 512;
	char* bytes = (char*)malloc(bufferSize);
	if(!bytes)
	{
		LOG(ERROR, "Could not allocate memory");
		return false;
	}

	uri_t uri;
	if(stringToUri(uri, url) && uri.protocol.equals("http"))
	{
		sFLASH_Init();
		sFLASH_EraseBulk();
		if(uri.port == 0) uri.port = 80;
		TCPClient c;
		if(c.connect(uri.host, uri.port))
		{
			c.printf("GET %s HTTP/1.1\r\n", uri.resource.c_str());
			c.printf("Host: %s\r\n", uri.host.c_str());
			c.printf("Connection: close\r\n");
			c.printf("\r\n");

			c.setTimeout(5000);
			if(c.find((char*)"\r\n\r\n"))
			{
				c.setTimeout(1000);
				size_t total_read = 0;
				size_t read = 0;
				do
				{
					read = c.readBytes(bytes, bufferSize);
					if(read)
					{
						sFLASH_WriteBuffer((const unsigned char*)bytes, 0x20000 + total_read, read);
					}
					total_read += read;
				} while(read);

				free(bytes);
				LOG(INFO, "Downloaded %d bytes to sFLASH:0x20000", total_read);
				c.stop();
				LOG(WARN, "Loading firmware...");
				delay(100);

//				FLASH_ModuleInfo(FLASH_SERIAL, 0x20000);
				System.factoryReset();
				return true;
			}
			LOG(ERROR, "Did not find beginning of data in stream");
			c.stop();
		}
		else
			LOG(ERROR, "Could not connect to %s:%d", uri.host.c_str(), uri.port);

	}
	else
		LOG(ERROR, "Firmware URL could not be validated; aborting.");
	free(bytes);
	return false;
#endif
}
