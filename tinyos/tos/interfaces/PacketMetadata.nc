
// Retreive interesting auxillary info about a packet

interface PacketMetadata {
  command uint8_t getLqi (message_t* msg);
  command uint8_t getRssi (message_t* msg);

  /**
   * Set the maximum number of times attempt message delivery
   * Default is 0
   * @param 'message_t* ONE msg'
   * @param maxRetries the maximum number of attempts to deliver
   *     the message
   */
  command void setRetries(message_t *msg, uint16_t maxRetries);

  /**
   * Set a delay between each retry attempt
   * @param msg
   * @param retryDelay the delay betweeen retry attempts, in milliseconds
   */
  command void setRetryDelay(message_t *msg, uint16_t retryDelay);

  /**
   * @param 'message_t* ONE msg'
   * @return the maximum number of retry attempts for this message
   */
  command uint16_t getRetries(message_t *msg);

  /**
   * @param 'message_t* ONE msg'
   * @return the delay between retry attempts in ms for this message
   */
  command uint16_t getRetryDelay(message_t *msg);

  /**
   * @param 'message_t* ONE msg'
   * @return TRUE if the message was delivered.
   */
  command bool wasDelivered(message_t *msg);

  /**
   * Tell a protocol that when it sends this packet, it should use synchronous
   * acknowledgments.
   * The acknowledgment is synchronous as the caller can check whether the
   * ack was received through the wasAcked() command as soon as a send operation
   * completes.
   *
   * @param 'message_t* ONE msg' - A message which should be acknowledged when transmitted.
   * @return SUCCESS if acknowledgements are enabled, EBUSY
   * if the communication layer cannot enable them at this time, FAIL
   * if it does not support them.
   */

  async command error_t requestAck(message_t* msg);

  /**
   * Tell a protocol that when it sends this packet, it should not use
   * synchronous acknowledgments.
   *
   * @param 'message_t* ONE msg' - A message which should not be acknowledged when transmitted.
   * @return SUCCESS if acknowledgements are disabled, EBUSY
   * if the communication layer cannot disable them at this time, FAIL
   * if it cannot support unacknowledged communication.
   */

  async command error_t noAck(message_t* msg);

  /**
   * Tell a caller whether or not a transmitted packet was acknowledged.
   * If acknowledgments on the packet had been disabled through noAck(),
   * then the return value is undefined. If a packet
   * layer does not support acknowledgements, this command must return always
   * return FALSE.
   *
   * @param 'message_t* ONE msg' - A transmitted message.
   * @return Whether the packet was acknowledged.
   *
   */

  async command bool wasAcked(message_t* msg);
}
