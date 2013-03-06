COMPONENT=NodeCollectC

PFLAGS += -DCC2420_DEF_CHANNEL=19
PFLAGS += -DCC2520_DEF_CHANNEL=19
# use rpl
PFLAGS += -DRPL_ROUTING -DRPL_STORING_MODE -I$(LOWPAN_ROOT)/tos/lib/net/rpl
# PFLAGS += -DRPL_OF_MRHOF

# this works around fragmentation in the RX buffer pool
PFLAGS += -DPPP_HDLC_RX_FRAME_LIMIT=1 -DPPP_HDLC_TX_FRAME_LIMIT=8

# if you set this, the stack won't use dhcp to assign addresses -- it
# will use this prefix combined with TOS_NODE_ID
#PFLAGS += -DIN6_PREFIX=\"2607:f018:800a:bcde:f012:3456:7890::\"

# derive short address from the dhcp address assignment, if possible
#PFLAGS += -DBLIP_DERIVE_SHORTADDRS

include $(MAKERULES)
