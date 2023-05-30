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

    @@tlbTable     = []
    @@outerPageTbl = Array.new((2 ** outerPg), -1)
    @@innerPageTbl = Array.new((2 ** innerPg), -1)
    @@physMem = Array.new((2 ** offset), -1)
  end
  
  def accessMemory(address)
    if pageAddress(address).length != 3
      puts 'ERROR: address length does not correspond to inner/outer paging dimensions; exiting...'
      exit 2
    end
    storeLRU(searchTlb(address), address)
  end

  def pageAddress(address)
    @out, @in = address, @offset = address
    @tot = @@outerPgSize + @@innerPgSize + @@offsetSize

    @possibleAddrs = (2 ** @tot) - 1 # possible address is (2^tot)-1; fail if over this value
    if @possibleAddrs < address
      raise "ERROR: this address cannot be represented using the address args passed; exiting..."
    end
    #input file for out, in, offset is in following format: X Y Z <X=out, Y=in, Z=offset>
    @out = address >> (@@innerPgSize + @@offsetSize) # Derive Outer pg from first few bits (X of input)

    x = @tot-1
    y = @tot-@@outerPgSize
    z = (x...y) # define range
    (z.first).downto(z.last).each{ |i| # Derive Inner pg value from center few bits (Y of input)
      @in = (@in & ~(1 << i))
    }
    @in = @in >> @@offsetSize

    x = @tot-1
    y = @tot-@@outerPgSize-@@innerPgSize
    z = (x...y) # define range
    (z.first).downto(z.last).each{ |i|
      @offset = @offset & ~(1 << i)
    }
    [@out, @in, @offset] # return <out/in/offset individual values>
  end

  def searchTlb(address)
    @i = 0
    for @i in 0...@@tlbTable.length
      @a = pageAddress(address) # find page table values to search for
      @b = pageAddress(@@tlbTable[@i]) # initialize check value
      if @a[0] == @b[0] and @a[1] = @b[1]
        return @i
      end
    end
    -1 # return invalid index if item can't be found in TLB
  end

  def storeLRU(cachedNdx, address)
    @paging = pageAddress(address)

    # if we have the memory in the TLB, we may directly access the phys memFrame
    if cachedNdx != -1
      @@tlbTable.delete_at(cachedNdx)
      @@tlbTable.push(address)
      @@accessTime += @@tlbCost
    else # remove least recently used item from TLB and add recent address to the end (most recent)
      if @@tlbTable.length == @@tlbCap
        @@tlbTable.delete_at(0)
      end
        @@tlbTable.push(address)
        @@accessTime += @@tlbCost

        # simulate r/w from outer pg table
        @@outerPageTbl[@paging[0]] = @paging[1]
        @@accessTime += @@physCost

        # simulate r/w from inner pg table
        @@innerPgTbl[@paging[0]] = @paging[2]
        @@accessTime += @@physCost
    end
    # For debugging, see paging of phys mem
    @@accessTime += @@physCost
    @@numAccesses += 1
  end

  def outputTlbAccess()
    puts(@@accessTime.to_s + " ")
    puts((@@accessTime.to_f/@@numAccesses.to_f)) # FIXME one significant decimal ONLY
  end
end
