
module DsscSimple
  Item = Struct.new(:status, :path)
  
  REGEXP_TIMESTAMP  = '\d\d\/\d\d\/\d\d\d\d \d\d:\d\d'
  REGEXP_VERSION    = '\d*\.\d*'
  WS                = '\s*'
  STATUS_WIDTH      = 10

  STATUS_OUTPUT = {
  :status_local         => ''.ljust(STATUS_WIDTH),
  :status_local_mod     => 'M'.ljust(STATUS_WIDTH),
  :status_unmanaged     => '?'.ljust(STATUS_WIDTH),
  :status_local_missing => '!'.ljust(STATUS_WIDTH),
  :status_cached        => ''.ljust(STATUS_WIDTH),
  :status_locked        => '     K'.ljust(STATUS_WIDTH),
  :status_locked_mod    => 'M    K'.ljust(STATUS_WIDTH),
  :status_rep_mod       => '     *'.ljust(STATUS_WIDTH),
  :status_rep_locked    => '     O'.ljust(STATUS_WIDTH),
  }
  require 'pp'


  class Report

    #need to take report and break down into status and full path
    #An Array of new Struct

    def initialize( path=Dir.pwd )
      @path = path
    end

    def display items
      Array( items ).each do |item|
        puts "#{STATUS_OUTPUT[item.status]} #{item.path}"
      end
    end

    def list_all
      result = calculate_report
      display result
      return result
    end


    def list_cached
      results = calculate_report.select do |item|
        item.status == :status_cached
      end
      
      display results
      return results
    end


    def clear_cache
      # clear cached results, reports will be regenerated
      @items   = nil
      @results = nil
    end


    def calculate_report
      @items ||= calculate_report_worker
    end

    def calculate_report_worker
      items         = []

      cached_results.each_with_index do |line, index|
        case line 
        when /^(\s*File\s*Up-to-date\s*Lock\s*\w*\*\s*#{REGEXP_VERSION}\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_locked, line.strip )
        
        when /^(\s*File\s*Up-to-date\s*Locally Modified\s*Lock\s*\w*\*\s*#{REGEXP_VERSION}\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_locked_mod, line.strip )

        when /^(File\s*Up-to-date\s*Locally Modified\s*Copy\s*#{REGEXP_VERSION}\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_local_mod, line.strip )
        
        when /^(\s*File\s*-\s*Unmanaged\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_unmanaged, line.strip) 
          
        when /^(\s*Folder\s*-\s*Unmanaged\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_unmanaged, line.strip) 

        when /^(\s*Link to Folder\s*-\s*Unmanaged\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_unmanaged, line.strip) 

        when /^(\s*Cached File\s*Up-to-date\s*Cache\s*#{REGEXP_VERSION}\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_cached,  line.strip) 

        when /^(\s*File\s*Up-to-date\s*Copy\s*#{REGEXP_VERSION}\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_local,  line.strip) 

        when /^(\s*Cached File\s*Needs Update\s*Cache\s*#{REGEXP_VERSION}\s*)/
          line[$1.to_s] = ''
          items << Item.new( :status_rep_mod,  line.strip) 

        when /^(\s*Cached File\s*Up-to-date\s*Cache\s*\w*\s*#{REGEXP_VERSION})/
          line[$1.to_s] = ''
          items << Item.new( :status_rep_locked,  line.strip)

        when /^(\s*Referenced File\s*Up-to-date\s*Reference\s*Refers to:\s*#{REGEXP_VERSION})/
          line[$1.to_s] = ''
          items << Item.new( :status_local_missing,  line.strip)

        when /^(\s*Folder\s*-\s*)/
          ## Ignore

        when /^Directory of: file:\/\//
          ## Ignore
        when /^\s*Object Type\s*Server Status\s*WS Status\s*Type\s*Locked By\s*Version\s*Name/
          ## Ignore
        when /^----------/
          ## Ignore
        when /^\s*$/
          ## Ignore
        else
          puts "#{index} : #{line}"
        end
      end

      #display items
      return items
    end

    def cached_results 
      @results ||= run_dssc_ls_mock 
    end

    def run_dssc_ls_mock
      #This is mocked in test to just load a results file
      f = open("| dssc ls -recursive -report OSDLUVN -path #{@path}")
      result = Array.new
      while (foo = f.gets)
        result << foo
      end
      
      return result
    end
  end
end

