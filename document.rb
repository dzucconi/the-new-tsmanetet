module Prawn
  class Document
    alias_method :orig_start_new_page, :start_new_page unless method_defined? :orig_start_new_page

    def run_before_new_page(&block)
      @run_before_new_page_blocks ||= Array.new
      @run_before_new_page_blocks <<  Proc.new(&block)
    end

    def run_after_new_page(&block)
      @run_after_new_page_blocks ||= Array.new
      @run_after_new_page_blocks <<  Proc.new(&block)
    end

    def start_new_page(options = {})
      run_blocks @run_before_new_page_blocks, options
      self.orig_start_new_page options
      run_blocks @run_after_new_page_blocks
    end

    protected

    def run_blocks(blocks, *args)
      return if !blocks || blocks.empty?
      blocks.each { |block| block.arity == 0 ? self.instance_eval(&block) : block.call(self, *args) }
    end
  end
end
