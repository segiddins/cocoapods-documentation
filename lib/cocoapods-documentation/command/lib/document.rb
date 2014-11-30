module Pod
  class Command
    class Lib
      class Document < Lib
        self.summary = 'Creates documentation for a Pod.'

        self.description = <<-DESC
          Documents the Pod using the files in the working directory.
        DESC

        self.arguments =[
          CLAide::Argument.new('NAME.podspec', false),
        ]

        def initialize(argv)
          @podspec_path = argv.shift_argument
          super
        end

        def validate!
          @podspec = Specification.from_file(podspec_to_document)
          super
        end

        def run
          UI.title "Documenting #{@podspec.name}" do
            documenter = CocoaPodsDocumentation::Documenter.new(@podspec, true)
            documenter.source = podspec_path.parent
            documenter.document!
          end
        end

        private

        def podspec_to_document
          @podspec_path ||= begin
            podspecs = Pathname.glob(Pathname.pwd + '*.podspec{.json,}')
            if podspecs.empty?
              raise Informative, 'Unable to find a podspec in the working ' \
                'directory'
            elsif podspec.count > 1
              raise Informative, 'Found more than one podspec in the working ' \
                'directory, please specify one explicitly.'
            end
            podspecs.first
          end
        end
      end
    end
  end
end
