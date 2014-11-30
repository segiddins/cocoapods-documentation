module Pod
  class Command
    class Spec
      class Document < Spec
        self.summary = 'Creates documentation for a Pod.'

        self.description = <<-DESC
          Documents the Pod referenced by the given podspec.
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
            documenter = CocoaPodsDocumentation::Documenter.new(@podspec, false)
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
