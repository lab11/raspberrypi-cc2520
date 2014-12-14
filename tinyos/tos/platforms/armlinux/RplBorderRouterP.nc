
/**
 * When packets leave a RPL domain, we're need to remove and RPL
 * headers which have been inserted and/or reencapsulate the packet.
 * This component hooks into the forwarding path to do this by
 * converting any RPL TLV options in IPv6 hop-by-hop options header to
 * PadN options.
 *
 * @author Stephen Dawson-Haggerty <stevedh@eecs.berkeley.edu>
 */

#include <lib6lowpan/ip.h>
#include <iprouting.h>
#include <RPL.h>

module RplBorderRouterP {
  uses {
    interface ForwardingEvents;
    interface IPPacket;
  }
}

implementation {

  event bool ForwardingEvents.initiate(struct ip6_packet *pkt,
                                       struct in6_addr *next_hop) {
    return TRUE;
  }

  event bool ForwardingEvents.approve(struct ip6_packet *pkt,
                                      struct in6_addr *next_hop) {
    int off;
    uint8_t nxt = IPV6_HOP;
    if (pkt->ip6_inputif == ROUTE_IFACE_PPP)
      return FALSE;

    /* remove any RPL options in the hop-by-hop header by converting
       them to a PadN option */
    off = call IPPacket.findHeader(pkt->ip6_data, pkt->ip6_hdr.ip6_nxt, &nxt);
    if (off < 0) {
      return TRUE;
    } else if (off == 0) {
      uint8_t length_in_bytes = 0;

      // Need to get rid of this header

      // Start by copying the next header value to the main packet
      pkt->ip6_hdr.ip6_nxt = pkt->ip6_data->iov_base[0];

      // Now figure out the length of the header to be skipped
      length_in_bytes = (pkt->ip6_data->iov_base[1] + 1) * 8;

      // Move this iov to skip that header
      pkt->ip6_data->iov_base += length_in_bytes;
      pkt->ip6_data->iov_len  -= length_in_bytes;

      // Update the main pkt len
      pkt->ip6_hdr.ip6_plen = htons(ntohs(pkt->ip6_hdr.ip6_plen) - (uint16_t) length_in_bytes);

      // Update UDP checksum, if needed
      if (pkt->ip6_hdr.ip6_nxt == IANA_UDP) {
        uint16_t udp_check;
        pkt->ip6_data->iov_base[6] = 0;
        pkt->ip6_data->iov_base[7] = 0;
        udp_check = htons(msg_cksum(&pkt->ip6_hdr, pkt->ip6_data, IANA_UDP));
        pkt->ip6_data->iov_base[6] = (udp_check & 0xFF);
        pkt->ip6_data->iov_base[7] = ((udp_check >> 8) & 0xFF);
      }

    } else {
      call IPPacket.delTLV(pkt->ip6_data, off, RPL_HBH_RANK_TYPE);
    }

    return TRUE;
  }

  event void ForwardingEvents.linkResult(struct in6_addr *dest,
                                         struct send_info *info) {

  }
}
