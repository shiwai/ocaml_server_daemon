function get_todos() {
    // Use Ajax to Get Todo data
    $.ajax({
        url: "/api/todos"
        }).done(function(data) {
            current_todos = JSON.parse(data);
            refresh_todo_view(current_todos);
        })
}

function insert_todos(name, value) {
    // Use Ajax to Insert Todo data
    $.ajax({
        url: "/api/todos",
        type: "post",
        data: {
            "name":name,
            "value":value
             }
        }).done(function(res) {
            console.log(res);
            get_todos();
        })
}

function refresh_todo_view (new_todos) {
    function make_child (index, todo) {
        return "<tr><td>" + (index+1) + "</td><td>" + todo["name"] + "</td><td>" + todo["value"] + "</td><td></td></tr>";
    }
    $todos = $('#todos tbody');
    // clear current view
    $todos.empty();
    html = "";
    for (var i = 0; i < new_todos.length; i++) {
        html += make_child(i, new_todos[i]);
    }
    $todos.append(html);
}

$('#get_todo').on('click', get_todos);
$('#post_todo').on('click', function(){
    $name_box = $("#task_name");
    $desc_box = $("#task_desc");
    var name = $name_box.val();
    var desc = $desc_box.val();
    insert_todos(name, desc);
    // initialize
    $name_box.val("");
    $desc_box.val("");
    });

// Initial Display
get_todos();
