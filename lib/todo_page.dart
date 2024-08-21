import 'package:flutter/material.dart';
import 'package:todo_list/database_helper.dart';
import 'package:todo_list/todo.dart';

class todoPage extends StatelessWidget {
  const todoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
  });
  
  @override
  State<StatefulWidget> createState() => _TodoList();
}

class _TodoList extends State<TodoList> {
  TextEditingController _namaCtrl = TextEditingController();
  TextEditingController _deskripsiCtrl = TextEditingController();
  TextEditingController _searchCtrl = TextEditingController();
  List<Todo> todoList = [];
  // Todo.dummyData
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async{
    // setState(() {
    //   todoList = todoList;
    //   });
    final todos = await dbHelper.getALlTodos();
    setState(() {
      todoList = todos;
    });
  }

  void addItem()async{
    await dbHelper.addTodo(Todo(_namaCtrl.text, _deskripsiCtrl.text));
    //todoList.add(Todo(_namaCtrl.text, _deskripsiCtrl.text));
    refreshList();

    _namaCtrl.text = '';
    _deskripsiCtrl.text = '';
  }

  void updateItem(int index, bool done) async{
      todoList[index].done = done;
      await dbHelper.updateTodo(todoList[index]);
      refreshList();
  }

  void deleteItem(int id)async{
    // todoList.removeAt(index);
    await dbHelper.deleteTodo(id);
    refreshList();
  }

  void cariTodo() async {
    String teks = _searchCtrl.text.trim();
    List<Todo> todos = [];
    if (teks.isEmpty){
      todos = await dbHelper.getALlTodos();
    }
    else{
      todos = await dbHelper.searchTodo(teks);
    }

    setState(() {
      todoList = todos;
    });
  }

  void tampilForm(){
    showDialog(context: context, 
    builder: (context)=> AlertDialog(
      insetPadding: EdgeInsets.all(20),
      title: Text("Tambah Todo"),
      actions: [
        ElevatedButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text("Tutup")),
        ElevatedButton(onPressed: (){
          addItem();
          Navigator.pop(context);
        }, child: Text("Tambah"))
      ],
      content: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            TextField(
              controller: _namaCtrl,
              decoration: InputDecoration(hintText:'Nama Todo'),),
            TextField(
              controller: _deskripsiCtrl,
               decoration: InputDecoration(hintText:'Deskripsi pekerjaan'),),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aplikasi Todo List'),
      centerTitle: true,),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tampilForm();
        },
        child: Icon(Icons.add_box), ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_){
                cariTodo();
              },
              decoration: InputDecoration(hintText: 'cari apa',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
            ),),
          Expanded(child: ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (context, index){
              return ListTile(
                leading: todoList[index].done
                ? IconButton( 
                  icon: const Icon(Icons.check_circle),
                  onPressed: (){
                    updateItem(index, !todoList[index].done);
                  },
                )
                : IconButton( 
                  icon: const Icon(Icons.radio_button_unchecked),
                  onPressed: (){
                    updateItem(index, !todoList[index].done);
                  },
                ),
                title: Text(todoList[index].nama),
                subtitle: Text(todoList[index].deskripsi),
                trailing: IconButton( 
                  icon: Icon(Icons.delete), 
                  onPressed:(){
                    deleteItem(todoList[index].id ?? 0);
                  },
                ),
              );
            }),
            ),
        ],
      ),
    );
  }


}