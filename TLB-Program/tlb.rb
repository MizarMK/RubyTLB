# frozen_string_literal: true

class TLB
  # class variables
  @@outerPgSize  = -1
  @@innerPgSize  = -1
  @@offsetSize   = -1
  @@physCost     = -1
  @@tlbCost      = -1
  @@tlbCap       = -1
  @@accessTime   = 0
  @@numAccesses  = 0
  @@tlbTable     = []
  @@outerPageTbl = []
  @@innerPgTbl   = []
  @@physMem      = []

  def initialize(outerPg, innerPg, offset, physCost, tlbCost, tlbCap)
    @@outerPgSize = outerPg
    @@innerPgSize = innerPg
    @@offsetSize = offset
    @@physCost = physCost
    @@tlbCost = tlbCost
    @@tlbCap = tlbCap
  end
  
  def accessMemory(address)
    if(pageAddress(address).length != 3)
      puts('ERROR: address length does not correspond to inner/outer paging dimensions; exiting...'
      SystemExit(2)
    end
    storeLRU(searchTlb(address), address)
  end

  def pageAddress(address)
    return []
  end

  def searchTlb(address)

  end

  def storeLRU(cachedNdx, address)

  end

  def outputTlbAccess()
    puts(@@accessTime.to_s + " ")
    puts((@@accessTime.to_f/@@numAccesses.to_f)) # FIXME one significant decimal ONLY
  end
end
