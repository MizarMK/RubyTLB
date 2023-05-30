# frozen_string_literal: true
# Driver for TLB Simulation
require_relative 'tlb'

#Read stdin for TLB details
# FIXME handle non-existent file
File.open("testinputs/input2.txt").each_with_index do |line, i|
   line.chomp!
   if i == 0 # Assign page dimensions
     @addressInfo = line.split(' ')
     @outerPg = @addressInfo[0].to_i
     @innerPg = @addressInfo[1].to_i
     @offset = @addressInfo[2].to_i

     if @outerPg < 1 or @innerPg < 1 or @offset < 1
       raise "ERROR: TLB address details must be positive; exiting..."
     end

     @totSize = @outerPg + @innerPg + @offset
     if @totSize > 32
       raise "ERROR: TLB address details exceeds 32 bits"
     end
   elsif i == 1 # assign
     @physCost = line.to_i
     if @physCost < 0
       raise "ERROR: Memory Access cost must be non-negative"
     end
   elsif i == 2
     @tlbInfo = line.split(" ")
     @tlbCap = @tlbInfo[0].to_i
     @tlbCost = @tlbInfo[1].to_i
     if @tlbCost < 0 or @tlbCap < 0
       raise "ERROR: TLB cost or size details invalid"
     end
     @tlb = TLB.new(@outerPg, @innerPg, @offset, @physCost, @tlbCost, @tlbCap) # generate TLB
   else # For remaining input (Addresses), parse and find cost
     address = line.to_i
     if address < 0
       raise "ERROR: address input may not be negative"
     end
     @tlb.accessMemory(address) # FIXME find out numberformatexception handling for non-numerical input
                                # FIXME handle other exceptions not including the above
   end
end
@tlb.outputTlbAccess()