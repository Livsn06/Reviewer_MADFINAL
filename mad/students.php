<?php
    require('connection.php');


    if($_SERVER['REQUEST_METHOD'] === 'GET'){
        global $conn;
        $sql = "SELECT * FROM student";
        $data = $conn->query($sql)->fetch_all(MYSQLI_ASSOC);
        echo json_encode($data);
    }


    if($_SERVER['REQUEST_METHOD'] === 'POST'){
        global $conn;

        $id = $_POST['id'];
        $name = $_POST['name'];
        $course = $_POST['course'];

        $sql = "INSERT INTO student (studno, name, course) VALUES ($id, '$name', '$course')";
        $response = $conn->query($sql);
        echo json_encode($response);
    }

    

    if($_SERVER['REQUEST_METHOD'] === 'DELETE'){
        global $conn;
        parse_str(file_get_contents("php://input"), $delete);
        
        if(isset($delete['id'])){

            $id = $delete['id'];

            $sql = "DELETE FROM student WHERE studno = $id";
            $response = $conn->query($sql);
            echo json_encode($response);
        }
    }

    if($_SERVER['REQUEST_METHOD'] === 'PUT'){
        global $conn;
        parse_str(file_get_contents("php://input"), $update);
        
        if(isset($update['id'])){

            $id = $update['id'];
            $name = $update['name'];
            $course = $update['course'];
            
            $sql = "UPDATE student SET name = '$name', course = '$course' WHERE studno = $id";
            $response = $conn->query($sql);
            echo json_encode($response);
        }
    }
?>