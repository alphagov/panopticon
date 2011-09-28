namespace :relatedness do
  task :draw => :environment do
    require 'open-uri'
    class Graph
      attr_accessor :nodes, :vertices
      private :nodes=, :vertices=

      def initialize
        self.nodes = []
        self.vertices = {}
      end

      def add_node node
        nodes << node
      end

      def connect node_a, node_b
        vertices[node_a] ||= []
        vertices[node_a] << node_b
        vertices[node_a].uniq!
      end

      def colour_for cluster
        case cluster
        when "published"
          "forestgreen"
        when "draft"
          "darkorange"
        else
          "lightpink"
        end
      end

      def draw into
        into << "digraph Relatedness {\n"
        into << %Q(  graph[overlap="false",layout="neato",splines=true,epsilon=0.2,margin="0,0"];\n)
        into << %Q(  node [shape=box, fontname="Gotham Light", style=filled, penwidth=1];\n)
        into << %Q(  edge [fontname="Georgia", len=2, fontsize=10, style=filled, arrowhead=none];\n)
        into << "\n"
        nodes.sort.group_by(&:cluster).each_pair do |cluster, nodes|
          into << "  subgraph #{cluster.gsub(/[^a-zA-Z0-0]/, '_')} {\n"
          into << "    node [style=filled,color=#{colour_for cluster}];\n"
          nodes.each do |node|
            into << "    #{node.to_dot}\n"
          end
          into << "  }\n"
        end
        into << "\n"
        vertices.each_pair.each do |origin_node, destination_nodes|
          destination_nodes.sort.each do |destination_node|
            into << "  #{origin_node.name} -> #{destination_node.name}\n"
          end
        end
        into << "}"
      end
    end

    class Node
      attr_accessor :artefact
      private :artefact, :artefact=

      def initialize artefact
        self.artefact = artefact
      end

      def to_dot
        %Q(#{name}[label="#{artefact.name}",labelURL="#{Plek.current.find('frontend')}/#{artefact.slug}"])
      end

      # FIXME: It'd be nice if Panopticon knew which slugs were published,
      # being drafted, reviewed, etc.
      def cluster
        open Plek.current.find("publisher") + '/publications/' + artefact.slug + '.json?edition=latest'
        "published"
      rescue OpenURI::HTTPError
        "not started"
      end

      include Comparable
      def <=> other
        sort_key <=> other.sort_key
      end

      def sort_key
        artefact.name
      end

      def name
        artefact.slug.gsub(/[^a-zA-Z0-9]/, '_')
      end
    end

    graph = Graph.new
    Artefact.all.each do |artefact|
      node = Node.new artefact
      graph.add_node node
      artefact.related_artefacts.each do |related|
        related_node = Node.new related
        graph.connect node, related_node
      end
    end
    graph.draw STDOUT
  end
end
