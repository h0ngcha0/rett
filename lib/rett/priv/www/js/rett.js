function rand(upper){
    return Math.floor(Math.random()*upper) + 50
}

(function($) {
    var router = null;
    var zIndex = 1;

    var sample_code = "expand_recs(M,List) when is_list(List) ->"
            + "[expand_recs(M,L)||L<-List];";

    var CodeEditorModel = Backbone.Model.extend({
        defaults: function() {
            return {
                x: rand(50),
                y: rand(50),
                z: zIndex,
                id: 0,
                code: sample_code
            }
        },

        initialize: function(spec) {
            this.set('id', spec.id);
            this.set('code', spec.code);
        },

        toJSON: function() {
            return {
                x: this.get('x'),
                y: this.get('y'),
                z: this.get('z'),
                id: this.get('id'),
                code: this.get('code')
            }
        }
    });

    var CodeEditors = Backbone.Collection.extend({
        model: CodeEditorModel
    });

    var CodeEditorView = Backbone.View.extend({
        render: function() {
            var textarea_id = "code_editor_"+this.model.get('id');
            var html = router.renderTemplate('code_editor', this.model.toJSON());
            $(this.el).html(html);
            $("#"+textarea_id).ready(function() {
                var editor = CodeMirror.fromTextArea(document.getElementById(textarea_id), {
                    lineNumbers: true,
                    matchBrackets: true,
                    extraKeys: {"Tab":  "indentAuto"},
                    theme: "erlang-dark"
                });
            });
            return this.el;
        }
    });

    window.RettRouter = Backbone.Router.extend({
        routes: {
            'editor': 'codeEditor',
        },

        cache: {},

        setView: function(view, title) {
            var html = view.render();
            $('#content').html(html);
            var newTitle = "Rett"
            if(!!title && title.length > 0) {
                newTitle += " - " + title;
            }
            document.title = newTitle;
            window.prettyPrint && prettyPrint();
        },

        loadTemplate: function(name) {
            var url = "static/views/" + name + ".handlebars";
            var template = $.ajax({url: url, async: false}).responseText;
            return Handlebars.compile(template);
        },

        renderTemplate: function(name, data) {
            var self = this;
            if(!self.cache[name]) {
                self.cache[name] = self.loadTemplate(name);
            }
            return self.cache[name](data || {});
        },

        codeEditor: function() {
            var model = new CodeEditorModel({});
            var view = new CodeEditorView({model: model});
            this.setView(view, "Code Editor")
        },

        start: function() {
            router = this;
            Backbone.history.start();

            this.navigate('editor', {trigger: true, replace: true});
        }
    });
})(jQuery);
