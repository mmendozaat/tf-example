variable "pipeline-queues" {
  type = map(list(string))
  default = {
    "q" : ["q1.fifo", "q2.fifo"],
    "a" : ["a1.fifo", "a2.fifo"]
    "b" : ["b1.fifo", "b2.fifo"]
  }
}