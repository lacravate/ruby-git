module Git
  class Branch < Path
    
    attr_accessor :full, :remote, :name
    
    # -- addition of track parameter for --t switch
    def initialize(base, name, track=nil)
    #
      @remote = nil
      @full = name
      @base = base
      @gcommit = nil
      @stashes = nil
      
      # -- addition of track attribute to implement
      #    --t switch
      @track = track
      name, remote = name.split(' ').first.split('/').reverse
      if remote
        @remote = Git::Remote.new(@base, remote)
        name = "#{remote}/#{name}"
      end
      @name = name
      #
    end
    
    def gcommit
      @gcommit ||= @base.gcommit(@full)
      @gcommit
    end
    
    def stashes
      @stashes ||= Git::Stashes.new(@base)
    end
    
    def checkout
      check_if_create
      @base.checkout(@full)
    end
    
    def archive(file, opts = {})
      @base.lib.archive(@full, file, opts)
    end
    
    # g.branch('new_branch').in_branch do
    #   # create new file
    #   # do other stuff
    #   return true # auto commits and switches back
    # end
    def in_branch (message = 'in branch work')
      old_current = @base.lib.branch_current
      checkout
      if yield
        @base.commit_all(message)
      else
        @base.reset_hard
      end
      @base.checkout(old_current)
    end
    
    def create
      check_if_create
    end
    
    def delete
      @base.lib.branch_delete(@name)
    end
    
    def current
      determine_current
    end
    
    def merge(branch = nil, message = nil)
      if branch
        in_branch do 
          @base.merge(branch, message)
          false
        end
        # merge a branch into this one
      else
        # merge this branch into the current one
        @base.merge(@name)
      end
    end
    
    def update_ref(commit)
      @base.lib.update_ref(@full, commit)
    end
    
    def to_a
      [@full]
    end
    
    def to_s
      @full
    end
    
    private 

      def check_if_create
        # -- addition of track attribute
        @base.lib.branch_new(@name, @track) rescue nil
        #
      end
      
      def determine_current
        @base.lib.branch_current == @name
      end
    
  end
end
