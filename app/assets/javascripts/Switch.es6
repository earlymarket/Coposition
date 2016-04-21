class Switch {
  constructor(user, domElement) {
    this.user = user;
    this.id = domElement.data().id;
    this.type = domElement.data().switch;
    this.attribute = domElement.data().attribute;
    this.inputDomElement = domElement.find('input');
    this.checked = this.inputDomElement.prop('checked');
    this.disabled = this.inputDomElement.prop('disabled');
  }

  changeDisableSwitches(state) {
    $(`div[data-id=${this.id}][data-switch=last_only].permission-switch`).find('input').prop("checked", false);
    $(`div[data-id=${this.id}].disable`).find('input').prop("disabled", state);
  }
}

class PermissionSwitch extends Switch {
  constructor(user, domElement, permissions) {
    super(user, domElement);
    this.permission = _.find(permissions, _.matchesProperty('id', this.id));
    this.attributeState = this.permission[this.attribute];
  }

  toggleSwitch() {
    COPO.permissions.iconToggle(this.type, this.id);
    if (this.type === "disallowed") {
      this.changeDisableSwitches(this.checked);
    }
    this.permission[this.attribute] = this.nextState();
    $.ajax({
      url: `/users/${this.user}/devices/${this.permission['device_id']}/permissions/${this.id}`,
      type: 'PUT',
      data: { permission: this.permission }
    });
  }

  nextState() {
    if(this.attributeState === "disallowed") {
      return "complete"
    } else if(this.type === "disallowed") {
      return "disallowed"
    } else if(this.attributeState === "complete") {
      return "last_only"
    } else if(this.attributeState === "last_only") {
      return "complete"
    } else {
      return !this.attributeState
    }
  }
}

class MasterSwitch extends Switch {
  constructor(user, domElement, permissions, idType) {
    super(user, domElement);
    this.permissions = permissions.filter(_.matchesProperty(idType, this.id));
  }

  toggleSwitch() {
    let self = this;
    this.permissions.forEach(function(permission){
      let pDomElement = $(`div[data-id=${permission.id}][data-switch=${self.type}].permission-switch`);
      let pSwitch = new PermissionSwitch(self.user, pDomElement, self.permissions);
      if ((pSwitch.disabled && pSwitch.type === 'last_only')){
        self.inputDomElement.prop("checked", false)
      } else if (self.checked !== pSwitch.checked) {
        pSwitch.inputDomElement.prop("checked", self.checked);
        pSwitch.checked = self.checked;
        pSwitch.toggleSwitch();
      }
    })
  }

  setState() {
    let switchesChecked = [];
    let self = this;

    this.permissions.forEach(function(permission){
      let pDomElement = $(`div[data-id=${permission.id}][data-switch=${self.type}].permission-switch`);
      switchesChecked.push(pDomElement.find('input').prop("checked"))
    })
    let newMasterCheckedState = _.every(switchesChecked)
    this.inputDomElement.prop("checked", newMasterCheckedState)

    if (this.type === "disallowed") {
      $(`div[data-id=${self.id}][data-switch=last_only].master`).find('input').prop("checked", false);
      let masters = $(`div[data-id=${self.id}].disable.master`).find('input');
      masters.prop("disabled", newMasterCheckedState);
    }
  }
}
