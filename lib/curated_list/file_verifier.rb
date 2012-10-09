module CuratedListImport
  class FileVerifier
    attr_accessor :filename

    def initialize(file)
      if file.respond_to?(:path)
        @filename = file.path
      else
        @filename = file.to_s
      end
    end

    def type
      mime_type.split('/').first
    end

    def sub_type
      mime_type.split('/').last
    end

    def mime_type
      shell_result = IO.popen(["file", "--brief", "--mime-type", filename],
        in: :close, err: :close)
      shell_result.read.chomp
    end

    def is_mime_type?(comparison_mime_type)
      mime_type == comparison_mime_type
    end
  end
end