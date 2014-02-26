COMPONENT=BorderRouterC

PFLAGS += -DCC2520_DEF_CHANNEL=21

###
### Set the addressing scheme
###
# Use IN6_PREFIX with static addressing modes
#PFLAGS += -DIN6_PREFIX="\"::\""
PFLAGS += -DBLIP_ADDR_AUTOCONF=1
PFLAGS += -DRPL_ADDR_AUTOCONF=0

###
### Configure BLIP
###
PFLAGS += -DBLIP_SEND_ROUTER_SOLICITATIONS=1
PFLAGS += -DBLIP_SEND_ROUTER_ADVERTISEMENTS=1

# derive short address from the dhcp address assignment, if possible
#PFLAGS += -DBLIP_DERIVE_SHORTADDRS

###
### Configure RPL
###
PFLAGS += -DRPL_ROUTING=1
PFLAGS += -DRPL_STORING_MODE=1 -I%T/lib/net/rpl
PFLAGS += -DRPL_OF_0=1
PFLAGS += -DRPL_OF_MRHOF=0


# this works around fragmentation in the RX buffer pool
PFLAGS += -DPPP_HDLC_RX_FRAME_LIMIT=1 -DPPP_HDLC_TX_FRAME_LIMIT=8



# derive short address from the dhcp address assignment, if possible
#PFLAGS += -DBLIP_DERIVE_SHORTADDRS

GOALS += blip

TINYOS_ROOT_DIR?=../..
include $(TINYOS_ROOT_DIR)/Makefile.include
