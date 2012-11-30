function rand(upper){
    return Math.floor(Math.random()*upper) + 50
}

(function($) {
    var app = null;
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

    var code_editors = new CodeEditorList;

    var CodeEditorView = Backbone.View.extend({
        tagName: "li",

        initialize: function() {
            this.html = app.renderTemplate('code_editor', this.model.toJSON());
        },

        render: function() {
            var textarea_id = "code_editor_"+this.model.get('id');
            $(this.el).html(this.html);
            $("#"+textarea_id).ready(function() {
                var editor = CodeMirror.fromTextArea(document.getElementById(textarea_id), {
                    lineNumbers: true,
                    matchBrackets: true,
                    extraKeys: {"Tab":  "indentAuto"},
                    theme: "erlang-dark"
                });
            });
            return this;
        }
    });

    var CodeEditorListView = Backbone.View.extend({
        tagName: "div",
        /*
        events: {
            "submit #new-code": "doSomething",
            "keypress #new-code":  "createOnEnter",
        },
         */
        render: function() {
            var self = this;
            self.$el.empty();
            _.forEach(self.model, function(ce, i) {
                // FIXME: for some reason ce doesn't contain the code editor model
                //        otherwise should use ce instead
                self.$el.append((new CodeEditorView({model: self.model.get(i+1)})).render().el)
            });
            return self
        }

        /*
        doSomething: function(e) {
            console.log("in doSomething")
        },

        createOnEnter: function(e) {
            console.log("in createOnEnter")
        }
         */
    });

    AppView = Backbone.View.extend({
        el: $("#rett"),
        cache: {},

        initialize: function() {
            app = this;
            //$('#new-code').submit(this.doSomething2);

            var code_editor1 = new CodeEditorModel({id:1, code:sample_code});
            var code_editor2 = new CodeEditorModel({id:2, code:"niubi2"});
            code_editors.add(code_editor1);
            code_editors.add(code_editor2);
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

        render: function() {
            var view = new CodeEditorListView({model: code_editors});

            var rendered_view = view.render();
            $('#code-editors').html(rendered_view.el);
            var newTitle = "Rett";
            var title = "Code Editor";
            if(!!title && title.length > 0) {
                newTitle += " - " + title;
            }
            document.title = newTitle;
            window.prettyPrint && prettyPrint();
            return this;
        },
    });

})(jQuery);
