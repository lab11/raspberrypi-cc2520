#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <netdb.h>
#include <errno.h>
#include <net/if.h>
#include <stdarg.h>
#include <fcntl.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>
#include <sys/ioctl.h>

#include "ini/ini.h"
#include "jsmn/jsmn.h"





typedef struct {
	const char* remotehost;
	uint16_t remoteport;
} config_ini_t;

#define MAC_ADDR_FILE "/sys/class/net/eth0/address"

config_ini_t cfg;

char json_id[] = "{\"Id\":\"00:11:22:33:44:55\"}";

char prefix[48] = {'\0'};

char macbuf[128];

int tcp_socket = -1;
int tun_file = -1;

fd_set rfds;
uint8_t nfds = 0;

// Runs a command on the local system using
// the kernel command interpreter.
int ssystem(const char *fmt, ...) {
	char cmd[128];
	va_list ap;
	va_start(ap, fmt);
	vsnprintf(cmd, sizeof(cmd), fmt, ap);
	va_end(ap);
	return system(cmd);
}

static int config_handler(void* user, const char* section, const char* name,
                          const char* value) {
	config_ini_t* cfg = (config_ini_t*) user;

	#define MATCH(s, n) strcmp(section, s) == 0 && strcmp(name, n) == 0

	if (MATCH("client", "remotehost")) {
		cfg->remotehost = strdup(value);
	} else if (MATCH("client", "remoteport")) {
		cfg->remoteport = atoi(value);
	}
	return 1;
}



int connect_tcp () {
	int ret;
	struct addrinfo hints;
    struct addrinfo *strmSvr;
    char port_str[6];


	// Start the connection process

	// Tell getaddrinfo() that we only want a TCP connection
	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_socktype = SOCK_STREAM;

	// Convert port number to a string
	snprintf(port_str, 6, "%d", cfg.remoteport);

	// Resolve the HOST to an IP address
	ret = getaddrinfo(cfg.remotehost, port_str, &hints, &strmSvr);
	if (ret < 0) {
		fprintf(stderr, "Could not resolve the host/port address: %s:%s\n",
			cfg.remotehost, port_str);
		fprintf(stderr, "%s", gai_strerror(ret));
		return -1;
	}

	// Create a TCP connection
	tcp_socket = socket(strmSvr->ai_family,
	                    strmSvr->ai_socktype,
	                    strmSvr->ai_protocol);
	if (tcp_socket < 0) {
		fprintf(stderr, "Could not create a socket.\n");
		fprintf(stderr, "%s\n", strerror(errno));
		return -1;
	}

	while (1) {
		// Connect to the socket
		ret = connect(tcp_socket, strmSvr->ai_addr, strmSvr->ai_addrlen);
		if (ret < 0) {
			fprintf(stderr, "Could not connect to socket.\n");
			fprintf(stderr, "%s\n", strerror(errno));
		} else {
			break;
		}
		printf("sleeeeeeeping\n");
		sleep(2);
	}

	freeaddrinfo(strmSvr);

	return 0;
}

int get_prefix () {
	int ret;
	ssize_t sent_len, read_len;
	uint8_t buf[4096];

	jsmn_parser p;
	jsmntok_t tok[10];

	int i;

	// Copy the mac address into the json blob
	memcpy(json_id+7, macbuf, 11);

	// Transmit the ID to the server
	sent_len = send(tcp_socket, json_id, strlen(json_id), 0);
	if (sent_len == -1) {
		fprintf(stderr, "Error sending MAC address via TCP\n");
		return -1;
	}
	printf("send %i bytes\n", (int) strlen(json_id));

	read_len = recv(tcp_socket, buf, 4095, 0);
	printf("read: %s\n", buf);


	// Parse the JSON response
	jsmn_init(&p);
	buf[read_len] = '\0';
	ret = jsmn_parse(&p, (char*) buf, tok, 10);
	if (ret != JSMN_SUCCESS) {
		fprintf(stderr, "Could not parse prefix value\n");
		return -1;
	}

#define TOKEN_STRING(js, t, s) \
	(strncmp(js+(t).start, s, (t).end - (t).start) == 0 \
	 && strlen(s) == (t).end - (t).start)

	for (i=0; i<9; i++) {
		if (TOKEN_STRING((char*) buf, tok[i], "Prefix")) {
			printf("gounf prefix %i %i\n", tok[i+1].start, tok[i+1].end-tok[i+1].start);
			memcpy(prefix, buf+tok[i+1].start, tok[i+1].end-tok[i+1].start);
			break;
		}
	}

	if (prefix[0] == '\0') {
		fprintf(stderr, "Could not decipher the prefix\n");
		return -1;
	}

	return 0;
}

int reconnect () {
	int ret;

	ret = connect_tcp();
	if (ret < 0) return ret;

	ret = get_prefix();
	if (ret < 0) return ret;

	return 0;
}





int main () {

    struct ifreq ifr;

    ssize_t read_len;
    ssize_t sent;
    uint8_t buf[4096];
    uint8_t cmdbuf[4096];
    int macfile;
    int ret;
    int i;






	// Parse a config file
	cfg.remotehost = NULL;
	cfg.remoteport = 0;
	ret = ini_parse("config.ini", config_handler, &cfg);
	if (ret < 0) {
		fprintf(stderr, "Could not open config.ini\n");
		fprintf(stderr, "The configuration file is required.\n");
		return -1;
	}
	if (cfg.remotehost == NULL || cfg.remoteport == 0) {
		fprintf(stderr, "Missing remotehost or remoteport in config.ini\n");
		return -1;
	}

	// Create the TUN interface

	tun_file = open("/dev/net/tun", O_RDWR);
	if (tun_file < 0) {
		// error
		fprintf(stderr, "Could not create a tun interface. errno: %i\n", errno);
		fprintf(stderr, "%s\n", strerror(errno));
		return -1;
	}

	// Clear the ifr struct
	memset(&ifr, 0, sizeof(ifr));

	// Select a TUN device
	ifr.ifr_flags = IFF_TUN | IFF_NO_PI;

	// Name the TUN device
	strncpy(ifr.ifr_name, "ipv6-umich", IFNAMSIZ);

	// Setup the interface
	ret = ioctl(tun_file, TUNSETIFF, (void *) &ifr);
	if (ret < 0) {
		fprintf(stderr, "ioctl could not set up tun interface\n");
		close(tun_file);
		return -1;
	}

	// Get our MAC address
	macfile = open(MAC_ADDR_FILE, O_RDONLY);
	if (macfile < 0) {
		fprintf(stderr, "Could not open file to get MAC address.\n");
		fprintf(stderr, "Have no way to get unique ID.\n");
		return -1;
	}

	// Get the MAC address
	read_len = read(macfile, macbuf, 128);
	if (read_len < 0) {
		fprintf(stderr, "Could not read MAC address file.\n");
		return -1;
	}
	close(macfile);



	reconnect();



	printf("prefix: %s\n", prefix);

	snprintf((char*) cmdbuf, 4096, "ifconfig %s up", ifr.ifr_name);
	ssystem((char*) cmdbuf);

	{
		char tun_ip_addr[48];
		strncpy(tun_ip_addr, prefix, 48);
		for (i=0; i<47; i++) {
			if (tun_ip_addr[i] == '/') {
				printf("found slash\n");
				tun_ip_addr[i] = 'f';
				tun_ip_addr[i+1] = '\0';
				break;
			}
		}


		snprintf((char*) cmdbuf, 4906, "ifconfig %s inet6 add %s", ifr.ifr_name, tun_ip_addr);
		printf("running %s\n", cmdbuf);
		ssystem((char*) cmdbuf);
	}

	snprintf((char*) cmdbuf, 4906, "ip -6 route add default via fe80::1 dev %s", ifr.ifr_name);
    ssystem((char*) cmdbuf);




    // Now that everything is setup, block on the two reads and shuttle some
    // data.

    while (1) {
	    // Clear the struct and set all fd that aren't 1
		FD_ZERO(&rfds);
		FD_SET(tcp_socket, &rfds);
		nfds = tcp_socket + 1;
		FD_SET(tun_file, &rfds);
		if (tun_file + 1 > nfds) {
			nfds = tun_file + 1;
		}

		// This blocks
		ret = select(nfds, &rfds, NULL, NULL, NULL);

		if (ret < 0) {
			if (errno == EINTR) {
				// suppress
			} else {
				// error
				fprintf(stderr, "select return error: %i\n", ret);
			}

		} else if (ret == 0) {
			fprintf(stderr, "select return 0.\n");

		} else {
			if (FD_ISSET(tcp_socket, &rfds)) {
				// read from tcp

				read_len = recv(tcp_socket, buf, 4096, 0);
				if (read_len == 0) {
					reconnect();
				} else if (read_len < 0) {
					switch (errno) {
						case EAGAIN:
							// errant wakeup, just loop
							break;
						default:
							fprintf(stderr, "Error occurred with reading TCP\n");
							reconnect();
					}
				} else {
					ret = write(tun_file, buf, read_len);
				}
			}

			if (FD_ISSET(tun_file, &rfds)) {
				// read from tun
				read_len = read(tun_file, buf, 4906);
				printf("got from tun 0x");
				for (i=0;i<read_len; i++) {
					printf("%02x", buf[i]);
				}
				printf("\n");
				if (read_len < 0) {
					switch (errno) {
						case EAGAIN:
							// errant wakeup, just loop
							break;
						default:
							fprintf(stderr, "Error occurred with reading TUN\n");
							return -1;
					}
				} else {
					sent = send(tcp_socket, buf, read_len, 0);
					printf("sent %i bytes\n", (int) sent);
					if (sent < 0) {
						reconnect();
					}
				}
			}


		}
	}





	return 0;
}


