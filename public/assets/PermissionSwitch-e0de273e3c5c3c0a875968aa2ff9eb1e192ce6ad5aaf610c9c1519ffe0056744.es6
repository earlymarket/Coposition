class PermissionSwitch {
  constructor(user, domElement) {
    this.user = user;
    this.id = domElement.data().id;
    this.switchtype = domElement.data().switchtype;
    this.attribute = domElement.data().attribute;
    this.inputDomElement = domElement.find('input');
    this.checked = this.inputDomElement.prop('checked');
    this.disabled = this.inputDomElement.prop('disabled');
  }

  changeDisableSwitches(state) {
    $(`div[data-id=${this.id}][data-switchtype=last_only].permission-switch`).find('input').prop("checked", false);
    $(`div[data-id=${this.id}].disable`).find('input').prop("disabled", state);
  }
}

class LocalSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions) {
    super(user, domElement);
    this.permission = _.find(permissions, _.matchesProperty('id', this.id));
    this.attributeState = this.permission[this.attribute];
  }

  toggleSwitch() {
    COPO.permissions.iconToggle(this.switchtype, this.id);
    if (this.switchtype === "disallowed") {
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
    } else if(this.switchtype === "disallowed") {
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

class MasterSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, idType) {
    super(user, domElement);
    this.permissions = permissions.filter(_.matchesProperty(idType, this.id));
  }

  toggleSwitch() {
    const SELF = this;
    SELF.permissions.forEach(function(permission){
      const PDOMELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${SELF.switchtype}].permission-switch`);
      const PSWITCH = new LocalSwitch(SELF.user, PDOMELEMENT, SELF.permissions);
      if ((PSWITCH.disabled && PSWITCH.switchtype === 'last_only')){
        SELF.inputDomElement.prop("checked", false)
      } else if (SELF.checked !== PSWITCH.checked) {
        PSWITCH.inputDomElement.prop("checked", SELF.checked);
        PSWITCH.checked = SELF.checked;
        PSWITCH.toggleSwitch();
      }
    })
  }

  setState() {
    const SWITCHESCHECKED = [];
    const SELF = this;

    SELF.permissions.forEach(function(permission){
      const PDOMELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${SELF.switchtype}].permission-switch`);
      SWITCHESCHECKED.push(PDOMELEMENT.find('input').prop("checked"))
    })
    const NEWMASTERCHECKEDSTATE = _.every(SWITCHESCHECKED)
    SELF.inputDomElement.prop("checked", NEWMASTERCHECKEDSTATE)

    if (SELF.switchtype === "disallowed") {
      $(`div[data-id=${SELF.id}][data-switchtype=last_only].master`).find('input').prop("checked", false);
      const MASTERS = $(`div[data-id=${SELF.id}].disable.master`).find('input');
      MASTERS.prop("disabled", NEWMASTERCHECKEDSTATE);
    }
  }
}
