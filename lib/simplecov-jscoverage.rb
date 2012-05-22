require 'simplecov-jscoverage/version'
require 'v8'
require 'cgi'

module SimpleCov
  module JSCoverage

    @coverage_full = {}

    def self.cover?
      return (ENV["JSCOV"] == "YES") || (ENV["COVERAGE"] == "YES")
    end

    def self.toolname
      "JSCoverage"
    end

    def self.report
      if cover?
        append_to_report @coverage_full if @coverage_full.length != 0
      end
    end

    def self.report_and_clear
      report
      @coverage_full.clear
    end

    def self.extract context
      return unless cover?
      coverage = context["_$jscoverage"]
      coverage_full = {}

      coverage.each do |filename, calls|
        source = source_for_file context, filename.to_s
        calls = convert_v8(calls)
        calls.shift

        coverage_full[filename] = { :calls => calls, :source => clean_lines(source)}
      end

      merge_full coverage_full
    end

    def self.convert_v8(value)
      if value.is_a?(V8::Array)
        result = []
        value.each do |val|
          result << convert_v8(val)
        end
      elsif value.is_a?(V8::Object)
        result = {}
        value.each do |key|
          result[key] = convert_v8(value[key])
        end
      else
        result = value
      end
      result
    end

    def self.merge_full coverage_full
      coverage_full.each do |file, coverage|
        if @coverage_full[file]

          @coverage_full[file][:calls] = @coverage_full[file][:calls].each_with_index.collect { |count, index|
            count + coverage[:calls][index] unless count.nil?
          }

        else
          @coverage_full[file] = coverage
        end
      end
    end

    def self.source_for_file context, file
      convert_v8 context.eval("_$jscoverage['#{file}'].source")
    end

    def self.clean_lines lines
      lines.collect{ |line| CGI.unescapeHTML(line) }
    end

    def self.append_to_report coverage_full
      coverage = {}

      coverage_full.each do |filename, coverage_per_file|
        coverage[filename] = coverage_per_file[:calls]
      end

      ::SimpleCov::ResultMerger.resultset.each do |command, data|
        if command == toolname && (Time.now.to_i - data["timestamp"]) < ::SimpleCov.merge_timeout
          coverage = data["coverage"].merge_resultset coverage
        end
      end

      merged_result = ::SimpleCov::Result.from_hash({toolname => { "coverage" => coverage, "timestamp" => Time.now.to_i }})
      ::SimpleCov::ResultMerger.store_result merged_result
    end

  end
end
