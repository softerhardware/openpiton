#include <stdint.h>
#include <stdbool.h>

#include "console.h"

static char mw_logo[] = "Hello, world!";

int main(void)
{
	console_init();

	puts(mw_logo);

	while (1) {
		unsigned char c = getchar();
		putchar(c);
		if (c == 13) // if CR send LF
			putchar(10);
	}
}
