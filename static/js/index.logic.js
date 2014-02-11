function get_todos() {
    // Use Ajax to Get Todo data
    $.ajax({
        url: "/api/todos"
        }).done(function(data) {
            current_todos = JSON.parse(data);
            refresh_todo_view(current_todos);
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
