
require 'spec_helper'

describe DsscSimple::Report do
  it "run_dssc_ls should be filtered" do
    
    report = DsscSimple::Report.new()
    report.stub!(:run_dssc_ls_mock) do
      absolute_filename = 
        ::File.absolute_path(
          ::File.join( 
            ::File.dirname(__FILE__), 'fixtures', 'mock_output.txt' 
          ) 
        )
      result = ''  
      ::File.open( absolute_filename, "rb"){ |f| result = f.read }
      
      result
    end
    
    display = report.list_cached

    report.list_all
    display.should == 'Not Nil'
  end
end


