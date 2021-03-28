document.querySelectorAll("#new-command-form").forEach((form) => {
  const addBtn = document.getElementById("new-command-btn");
  const name = document.getElementById("command_name_field");
  const input = name.querySelector(".input");
  const check = document.getElementById("new-command-check");
  addBtn.addEventListener("click", () => {
    form.style.display = "block";
    addBtn.style.display = "none";
    input.focus();
  });
  name.addEventListener("click", () => {
    console.log("click");
    input.focus();
  });
  input.addEventListener("input", (event) => {
    const hiddenField = document.getElementById("command_name");
    hiddenField.value = input.innerHTML;
  });
  input.addEventListener("keydown", (event) => {
    if (event.code === "Enter") {
      event.preventDefault();
      form.submit();
    }
  });
  check.addEventListener("click", () => {
    form.submit();
  });
});
