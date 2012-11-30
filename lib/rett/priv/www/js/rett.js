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
        },

        clear: function() {
            this.destroy();
        }
    });

    var CodeEditorList = Backbone.Collection.extend({
        model: CodeEditorModel
    });

    var g_code_editors = new CodeEditorList;

    var CodeEditorView = Backbone.View.extend({
        tagName: "li",

        initialize: function() {
            console.log("in codeeditorview"),
            console.log(this.model.toJSON());
            this.html = router.renderTemplate('code_editor', this.model.toJSON());
        },

        render: function() {
            var textarea_id = "code_editor_"+this.model.get('id');
            console.log("textarea_id:");
            console.log(textarea_id);
            console.log(this.html);
            $(this.el).html(this.html);
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

    var CodeEditorListView = Backbone.View.extend({
        render: function() {
            var self = this;
            console.log("model in code editor list view");
            console.log(this.model.get(1));
            /*
             _.each(this.model, function(ce) {
                console.log("fucking hell:");
                console.log(ce);
                self.$el.append((new CodeEditorView({model: ce})).render())
            });
             */
            self.$el.append((new CodeEditorView({model: this.model.get(1)})).render());
            self.$el.append((new CodeEditorView({model: this.model.get(2)})).render());
            console.log("after codeeditorview is called");
            return this.el
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
            var code_editor1 = new CodeEditorModel({id:1, code:"niubi1"});
            var code_editor2 = new CodeEditorModel({id:2, code:"niubi2"});
            g_code_editors.add(code_editor1);
            g_code_editors.add(code_editor2);
            console.log("g_code_editors after add:");
            console.log(g_code_editors.toJSON());
            var view = new CodeEditorListView({model: g_code_editors});
            this.setView(view, "Code Editor")
        },

        start: function() {
            router = this;
            Backbone.history.start();

            this.navigate('editor', {trigger: true, replace: true});
        }
    });
})(jQuery);
