(function($) {
    var router = null;

    var sample_code = "expand_recs(M,List) when is_list(List) ->"
            + "[expand_recs(M,L)||L<-List];"

    var CodeEditorModel = Backbone.Model.extend({
        initialize: function(spec) {
            this.set('x', 10);
            this.set('y', 10);
            this.set('z', 10);
            this.set('code', spec.code);
        },

        toJSON: function() {
            return {
                x: this.get('x'),
                y: this.get('y'),
                z: this.get('z'),
                code: this.get('code')
            }
        }
    });

    var CodeEditorView = Backbone.View.extend({
        render: function() {
            var html = router.renderTemplate('code_editor', this.model.toJSON());
            $(this.el).html(html);
            $("#code_editor").ready(function() {
                var editor = CodeMirror.fromTextArea(document.getElementById("code_editor"), {
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
            var model = new CodeEditorModel({code: sample_code});
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
